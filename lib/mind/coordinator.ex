defmodule Mind.Coordinator do
  alias Mind.{Config, Cluster, Store, Remote}

  def put(id, key, value) do
    replicas = Config.Store.key_replicas(id)
    quorum = Config.Store.write_quorum(id)

    snapshot = Cluster.snapshot(id, key, replicas)

    request = %Remote.Request{
      nodes: snapshot.nodes,
      mfa: {Store, :put, [id, key, value]},
      quorum: quorum,
      timeout_ms: 5000
    }

    case Remote.run(id, request) do
      {:ok, _results} -> :ok
      {:timeout, _results} -> {:error, :timeout}
    end
  end

  def fetch(id, key) do
    replicas = Config.Store.key_replicas(id)
    quorum = Config.Store.read_quorum(id)

    snapshot = Cluster.snapshot(id, key, replicas)

    request = %Remote.Request{
      nodes: snapshot.nodes,
      mfa: {Store, :fetch, [id, key]},
      quorum: quorum,
      timeout_ms: 5000
    }

    case Remote.run(id, request) do
      {:ok, [result | _rest]} -> result
      {:timeout, _results} -> {:error, :timeout}
    end
  end
end
