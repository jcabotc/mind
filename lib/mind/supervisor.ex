defmodule Mind.Supervisor do
  use Supervisor

  alias Mind.{Store, Cluster}

  def start_link(config),
    do: Supervisor.start_link(__MODULE__, config, name: config.id)

  def init(%{id: id} = config) do
    children = [
      {Config.Store, config: config},
      {Store, id: id},
      {Cluster.Tracker, id: id},
      {Remote.Caller.Supervisor, id: id},
      {Remote.Runner.Supervisor, id: id},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
