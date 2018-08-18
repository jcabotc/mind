defmodule Mind.Remote.Caller.Supervisor do
  alias Mind.Remote.Caller

  def child_spec(opts),
    do: %{id: __MODULE__, start: {__MODULE__, :start_link, [opts]}}

  def start_link(opts),
    do: Task.Supervisor.start_link(opts)

  def run(sup, runner_sup, request) do
    task = Task.Supervisor.async(sup, fn ->
      Caller.run(runner_sup, request)
    end)

    Task.await(task)
  end
end
