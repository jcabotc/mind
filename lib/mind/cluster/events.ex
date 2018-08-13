defmodule Mind.Cluster.Events do
  use DynamicSupervisor

  alias __MODULE__.Handler
  @name __MODULE__

  def start_link(opts) do
    opts = Keyword.put(opts, :name, @name)

    DynamicSupervisor.start_link(__MODULE__, :ok, opts)
  end

  def subscribe(sup \\ @name, callback) when is_function(callback, 1) do
    spec = {Handler, callback}

    DynamicSupervisor.start_child(sup, spec)
  end

  def notify(sup \\ @name, event) do
    for {_, pid, _, _} <- Supervisor.which_children(sup) do
      Handler.notify(pid, event)
    end

    :ok
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
