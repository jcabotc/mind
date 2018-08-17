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

  def subscribe(cluster, callback) do
    cluster
    |> get_events()
    |> Events.subscribe(callback)
  end

  def snapshot(cluster, key) do
    cluster
    |> get_tracker()
    |> Tracker.snapshot(key)
  end

  defp get_events(cluster),
    do: :"#{cluster}.Events"

  defp get_tracker(cluster),
    do: :"#{cluster}.Tracker"
end
