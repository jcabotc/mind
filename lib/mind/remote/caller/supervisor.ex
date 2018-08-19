defmodule Mind.Remote.Caller.Supervisor do
  alias Mind.Remote.Caller

  def child_spec(opts) do
    id = Keyword.fetch!(opts, :id)

    %{id: __MODULE__, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id),
    do: Task.Supervisor.start_link(name: via(id))

  def run(id, request) do
    task = Task.Supervisor.async(via(id), fn ->
      Caller.run(id, request)
    end)

    Task.await(task)
  end

  defp via(id),
    do: Mind.Registry.via(id, __MODULE__)
end
