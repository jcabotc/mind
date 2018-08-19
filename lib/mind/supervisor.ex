defmodule Mind.Supervisor do
  use Supervisor

  alias Mind.{Store, Cluster, Remote}

  def start_link(config),
    do: Supervisor.start_link(__MODULE__, config, name: config.id)

  def init(config) do
    children = [
      {Config.Store, config: config},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
