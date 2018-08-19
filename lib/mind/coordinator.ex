defmodule Mind.Coordinator do
  alias Mind.{Config, Cluster, Store, Remote}

  def put(id, key, value) do
    mfa = {Store, :put, [id, key, value]}
    quorum = Config.Store.write_quorum(id)

    case perform_request(id, key, mfa, quorum) do
      {:ok, _results} -> :ok
      {:timeout, _results} -> {:error, :timeout}
    end
  end

  def fetch(id, key) do
    mfa = {Store, :fetch, [id, key]}
    quorum = Config.Store.read_quorum(id)

    case perform_request(id, key, mfa, quorum) do
      {:ok, [result | _rest]} -> result
      {:timeout, _results} -> {:error, :timeout}
    end
  end

  defp perform_request(id, key, mfa, quorum) do
    replicas = Config.Store.key_replicas(id)
    snapshot = Cluster.snapshot(id, key, replicas)

    request = %Remote.Request{
      nodes: snapshot.nodes,
      mfa: mfa,
      quorum: quorum,
      timeout_ms: 5000
    }

    Remote.run(id, request)
  end
end
