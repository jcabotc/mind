defmodule Mind.Cluster.RingTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster.Ring

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

    token = Ring.token(ring, key)
    assert is_integer(token)
  end
end
