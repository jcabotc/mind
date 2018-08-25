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
    ref = make_ref()

    schedule_timeout(query, caller_pid, ref)
    run_on_each_node(query, id, caller_pid, ref)

    wait_for_quorum(query, ref)
  end

  defp schedule_timeout(%{timeout_ms: timeout_ms}, caller_pid, ref),
    do: Process.send_after(caller_pid, {:timeout, ref}, timeout_ms)

  defp run_on_each_node(query, id, caller_pid, ref),
    do: Enum.each(query.nodes, &Runner.run(id, &1, query, caller_pid, ref))

  defp wait_for_quorum(%{quorum: quorum}, ref),
    do: gather_results([], quorum, ref)

  defp gather_results(results, 0, _ref),
    do: {:ok, results}

  defp gather_results(results, remaining, ref) do
    receive do
      {:timeout, ^ref} ->
        {:timeout, results}

      {:done, result, ^ref} ->
        gather_results([result | results], remaining - 1, ref)
    end
  end

  def via(id),
    do: Mind.Registry.via(id, __MODULE__.Supervisor)
end
