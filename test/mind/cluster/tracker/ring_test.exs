defmodule Mind.Cluster.Tracker.RingTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster.Tracker.Ring

  test "add and remove nodes" do
    ring =
      Ring.new([:a, :b])
      |> Ring.add(:c)
      |> Ring.remove(:b)

    key = "asdf"

    nodes =
      ring
      |> Ring.key_stream(key)
      |> Enum.to_list()

    assert Enum.sort(nodes) == [:a, :c]

    assert {token, node} = Ring.token(ring, key)
    assert is_integer(token)
    assert node in [:a, :c]
  end
end
