defmodule Mind.Coordinator do
  alias Mind.{Config, Cluster, Store}
  alias __MODULE__.Query

  @timeout_ms 5000

  def put(id, key, value) do
    snapshot = get_snapshot(id, key)
    quorum = Config.Store.write_quorum(id)
    mfa = {Store, :put, [id, key, value]}

    case run_query(id, snapshot, quorum, mfa) do
      {:ok, _results} -> :ok
      {:timeout, _partial_results} -> {:error, :timeout}
    end
  end

  def fetch(id, key) do
    snapshot = get_snapshot(id, key)
    quorum = Config.Store.read_quorum(id)
    mfa = {Store, :fetch, [id, key]}

    case run_query(id, snapshot, quorum, mfa) do
      {:ok, [result | _rest]} -> result
      {:timeout, _partial_results} -> {:error, :timeout}
    end
  end

  defp get_snapshot(id, key) do
    replicas = Config.Store.key_replicas(id)

    Cluster.snapshot(id, key, replicas)
  end

  defp run_query(id, snapshot, quorum, mfa) do
    query =
      %Query{
        nodes: snapshot.nodes,
        mfa: mfa,
        quorum: quorum,
        timeout_ms: @timeout_ms
      }

    Query.run(id, query)
  end
end
