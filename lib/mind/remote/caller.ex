defmodule Mind.Remote.Caller do
  alias Mind.Remote.Runner

  def run(runner_sup, request) do
    %{
      nodes: nodes,
      mfa: mfa,
      quorum: quorum,
      timeout_ms: timeout_ms
    } = request

    self_pid = self()

    schedule_timeout(timeout_ms, self_pid)
    remote_run(nodes, runner_sup, mfa, self_pid)

    wait_for_quorum(quorum)
  end

  defp schedule_timeout(timeout_ms, self_pid),
    do: Process.send_after(self_pid, :timeout, timeout_ms)

  def remote_run(nodes, runner_sup, mfa, self_pid) do
    Enum.each(nodes, fn node ->
      Runner.Supervisor.run(runner_sup, node, mfa, self_pid)
    end)
  end

  defp wait_for_quorum(quorum, count \\ 0, results \\ [])

  defp wait_for_quorum(quorum, quorum, results),
    do: {:ok, results}

  defp wait_for_quorum(quorum, count, results) do
    receive do
      :timeout ->
        {:timeout, results}

      {:done, result} ->
        wait_for_quorum(quorum, count + 1, [result | results])
    end
  end
end
