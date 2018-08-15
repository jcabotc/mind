defmodule Mind.Cluster.RingTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster.Ring

  test "add and remove nodes" do
    ring =
      Ring.new([:a, :b])
      |> Ring.add(:c)
      |> Ring.remove(:b)

    key = "asdf"
    assert {:ok, stream} = Ring.key_stream(ring, key)

    nodes = Enum.to_list(stream)
    assert Enum.sort(nodes) == [:a, :c]
  end
end
