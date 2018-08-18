defmodule Mind.Supervisor do
  use Supervisor

  alias Mind.{Store, Cluster, Remote}

  def start_link(opts) do
    store = Keyword.fetch!(opts, :store_name)
    cluster = Keyword.fetch!(opts, :cluster_name)
    remote = Keyword.fetch!(opts, :remote_name)

    Supervisor.start_link(__MODULE__, {store, cluster, remote}, opts)
  end

  def init({store, cluster, remote}) do
    children =
      Store.child_specs(name: store) ++
        Cluster.child_specs(name: cluster) ++ Remote.child_specs(name: remote)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
