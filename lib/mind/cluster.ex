defmodule Mind.Cluster do
  alias __MODULE__.{Tracker, Events}

  def child_specs(opts) do
    cluster = Keyword.fetch!(opts, :name)

    events = get_events(cluster)
    tracker = get_tracker(cluster)

    [
      Events.child_spec(name: events),
      Tracker.child_spec([events, name: tracker])
    ]
  end

  def nodes(cluster, key, limit) do
    cluster
    |> get_tracker()
    |> Tracker.nodes(key, limit)
  end

  def token(cluster, key) do
    cluster
    |> get_tracker()
    |> Tracker.token(key)
  end

  defp get_events(cluster),
    do: :"#{cluster}.Events"

  defp get_tracker(cluster),
    do: :"#{cluster}.Tracker"
end
