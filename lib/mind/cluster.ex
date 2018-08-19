defmodule Mind.Cluster do
  alias __MODULE__.Tracker

  def snapshot(id, key),
    do: Tracker.snapshot(id, key)
end
