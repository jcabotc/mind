defmodule Mind.Cluster do
  alias __MODULE__.Tracker

  def child_specs(opts) do
    cluster = Keyword.fetch!(opts, :name)

    [Tracker.child_spec(name: get_tracker(cluster))]
  end

  def snapshot(cluster, key) do
    cluster
    |> get_tracker()
    |> Tracker.snapshot(key)
  end

  defp get_tracker(cluster),
    do: :"#{cluster}.Tracker"
end
