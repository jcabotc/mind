defmodule Mind.Cluster.Events do
  use DynamicSupervisor

  alias __MODULE__.Handler

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, opts)
  end

  def subscribe(sup, callback) when is_function(callback, 1) do
    spec = {Handler, callback}

    DynamicSupervisor.start_child(sup, spec)
  end

  def notify(sup, event) do
    for {_, pid, _, _} <- Supervisor.which_children(sup),
      do: Handler.notify(pid, event)

    :ok
  end

  def init(:ok),
    do: DynamicSupervisor.init(strategy: :one_for_one)
end
