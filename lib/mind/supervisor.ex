defmodule Mind.Supervisor do
  use Supervisor

  alias Mind.{Store, Cluster}

  def start_link(opts) do
    store = Keyword.fetch!(opts, :store_name)
    cluster = Keyword.fetch!(opts, :cluster_name)

    Supervisor.start_link(__MODULE__, {store, cluster}, opts)
  end

  def init({store, cluster}) do
    children = Store.child_specs(store) ++ Cluster.child_specs(cluster)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
