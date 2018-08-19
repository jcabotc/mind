defmodule Mind.Cluster.TrackerTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster.{Tracker, Snapshot}

  defp get_snapshot(key, state),
    do: Tracker.handle_call({:snapshot, key}, :from, state)

  defp node_up(node, state),
    do: Tracker.handle_info({:node_up, node}, state)

  defp node_down(node, state),
    do: Tracker.handle_info({:node_down, node}, state)

  defp node_timeout(node, state),
    do: Tracker.handle_info({:node_timeout, node}, state)

  test "handle_* functions" do
    current_node = Node.self()

    # Start cluster (adds the current node)
    assert {:ok, state} = Tracker.init(:ok)

    # Get snapshot for a key (only current node)
    expected_snapshot = %Snapshot{
      key: "key",
      nodes: [current_node]
    }

    assert {:reply, expected_snapshot, state} == get_snapshot("key", state)

    # Add 2 nodes
    assert {:noreply, state} = node_up(:node_1, state)
    assert {:noreply, state} = node_up(:node_2, state)

    # Get snapshot for a key (2 out of the 3 up nodes)
    assert {:reply, snapshot, state} = get_snapshot("key", state)
    assert %Snapshot{key: "key", nodes: nodes} = snapshot

    assert Enum.sort(nodes) == Enum.sort([current_node, :node_1, :node_2])

    # One node down
    assert {:noreply, state} = node_down(:node_1, state)

    # Get snapshot for a key (the remaining 2)
    assert {:reply, snapshot, state} = get_snapshot("key", state)
    assert %Snapshot{key: "key", nodes: nodes} = snapshot

    assert Enum.sort(nodes) == Enum.sort([current_node, :node_2])

    # Down node timeout
    assert {:noreply, _state} = node_timeout(:node_1, state)
  end
end
