defmodule Mind.Coordinator do
  alias Mind.{Config, Cluster, Store}
  alias __MODULE__.Query

  @timeout_ms 5000

  def put(id, key, value) do
    replicas = Config.Store.key_replicas(id)
    quorum = Config.Store.write_quorum(id)

    mfa = {Store, :put, [id, key, value]}
    snapshot = Cluster.snapshot(id, key, replicas)

    query = build_query(snapshot, mfa, quorum)

    case Query.run(id, query) do
      {:ok, _results} -> :ok
      {:timeout, _results} -> {:error, :timeout}
    end
  end

  def fetch(id, key) do
    replicas = Config.Store.key_replicas(id)
    quorum = Config.Store.read_quorum(id)

    mfa = {Store, :fetch, [id, key]}
    snapshot = Cluster.snapshot(id, key, replicas)

    query = build_query(snapshot, mfa, quorum)

    case Query.run(id, query) do
      {:ok, [result | _rest]} -> result
      {:timeout, _results} -> {:error, :timeout}
    end
  end

  defp build_query(snapshot, mfa, quorum) do
    %Query{
      nodes: snapshot.nodes,
      mfa: mfa,
      quorum: quorum,
      timeout_ms: @timeout_ms
    }
  end
end
