defmodule Mind.Cluster do
  alias __MODULE__.Tracker

  def snapshot(id, key, replicas),
    do: Tracker.snapshot(id, key, replicas)
end
