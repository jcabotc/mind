defmodule Mind.Coordinator.Query.Runner do
  def child_spec(opts) do
    id = Keyword.fetch!(opts, :id)

    %{id: __MODULE__, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id),
    do: Task.Supervisor.start_link(name: name(id))

  def run(id, node, query, caller_pid) do
    %{mfa: {mod, fun, args}} = query
    sup = {name(id), node}

    Task.Supervisor.start_child(sup, fn ->
      result = apply(mod, fun, args)

      send(caller_pid, {:done, result})
    end)
  end

  def name(id),
    do: :"#{id}.Coordinator.Runner.Supervisor"
end
