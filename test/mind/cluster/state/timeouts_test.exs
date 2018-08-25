defmodule Mind.Cluster.State.TimeoutsTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster.State.Timeouts

  test "add and pop timeouts" do
    timeouts =
      Timeouts.new()
      |> Timeouts.add(:node_1, :ref_1)
      |> Timeouts.add(:node_2, :ref_2)

    assert {:ok, :node_1, timeouts} = Timeouts.pop_by_ref(timeouts, :ref_1)
    assert :not_found = Timeouts.pop_by_ref(timeouts, :ref_1)

    assert timeouts = Timeouts.remove_by_node(timeouts, :node_1)
    assert :not_found = Timeouts.pop_by_ref(timeouts, :ref_1)

    assert {:ok, :ref_2, timeouts} = Timeouts.pop_by_node(timeouts, :node_2)
    assert :not_found = Timeouts.pop_by_ref(timeouts, :node_2)
  end
end
