defmodule Mind.Coordinator.Query.Caller do
  alias Mind.Coordinator.Query.Runner

  def child_spec(opts) do
    id = Keyword.fetch!(opts, :id)

    %{id: __MODULE__, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id),
    do: Task.Supervisor.start_link(name: via(id))

  def run(id, query) do
    task =
      Task.Supervisor.async(via(id), fn ->
        do_run(id, query)
      end)

    Task.await(task)
  end

  defp do_run(id, query) do
    caller_pid = self()

    schedule_timeout(query, caller_pid)
    run_on_each_node(query, id, caller_pid)

    wait_for_quorum(query)
  end

  defp schedule_timeout(%{timeout_ms: timeout_ms}, caller_pid),
    do: Process.send_after(caller_pid, :timeout, timeout_ms)

  defp run_on_each_node(query, id, caller_pid),
    do: Enum.each(query.nodes, &Runner.run(id, &1, query, caller_pid))

  defp wait_for_quorum(%{quorum: quorum}),
    do: gather_results([], quorum)

  defp gather_results(results, 0),
    do: {:ok, results}

  defp gather_results(results, remaining) do
    receive do
      :timeout ->
        {:timeout, results}

      {:done, result} ->
        gather_results([result | results], remaining - 1)
    end
  end

  def via(id),
    do: Mind.Registry.via(id, __MODULE__.Supervisor)
end
