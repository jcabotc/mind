defmodule Mind.Cluster.MembersTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster.Members

  test "add and remove nodes" do
    members =
      Members.new([:a, :b, :c], :up)
      |> Members.set(:c, :down)
      |> Members.set(:d, :down)
      |> Members.delete(:b)

    assert Members.status(members, :a) == :up
    assert Members.status(members, :b) == :unknown
    assert Members.status(members, :c) == :down
    assert Members.status(members, :d) == :down
  end
end
