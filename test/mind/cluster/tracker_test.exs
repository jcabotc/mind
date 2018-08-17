defmodule Mind.Cluster.TrackerTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster.{Tracker, Events}

  defp get_nodes(key, limit, state),
    do: Tracker.handle_call({:nodes, key, limit}, :from, state)

  defp get_token(key, state),
    do: Tracker.handle_call({:token, key}, :from, state)

  defp node_up(node, state),
    do: Tracker.handle_info({:node_up, node}, state)

  defp node_down(node, state),
    do: Tracker.handle_info({:node_down, node}, state)

  defp node_timeout(node, state),
    do: Tracker.handle_info({:node_timeout, node}, state)

  @events_name :"#{__MODULE__}_events"

  test "handle_* functions" do
    current_node = Node.self()
    test_pid = self()

    # Setup cluster events
    {:ok, events} = start_supervised({Events, name: @events_name})

    callback = fn event ->
      send(test_pid, {:notified, event})
      :ok
    end

    assert {:ok, _pid} = Events.subscribe(events, callback)

    # Start cluster (adds the current node)
    assert {:ok, state} = Tracker.init(events)
    assert_receive {:notified, {:node_added, ^current_node}}

    # Get nodes for a key (only current node)
    assert {:reply, nodes, state} = get_nodes("key", 2, state)
    assert [current_node] == nodes

    # Add 2 nodes
    assert {:noreply, state} = node_up(:node_1, state)
    assert {:noreply, state} = node_up(:node_2, state)
    assert_receive {:notified, {:node_added, :node_1}}
    assert_receive {:notified, {:node_added, :node_2}}

    # Get nodes for a key (2 out of the 3 up nodes)
    assert {:reply, nodes, state} = get_nodes("key", 2, state)
    unique_nodes = Enum.uniq(nodes)
    assert Enum.count(unique_nodes) == 2
    assert Enum.all?(nodes, &(&1 in [current_node, :node_1, :node_2]))

    # One node down
    assert {:noreply, state} = node_down(:node_1, state)

    # Get nodes for a key (the remaining 2)
    assert {:reply, nodes, state} = get_nodes("key", 2, state)
    assert Enum.sort(nodes) == Enum.sort([current_node, :node_2])

    # Down node timeout
    assert {:noreply, state} = node_timeout(:node_1, state)
    assert_receive {:notified, {:node_removed, :node_1}}

    # Get a token
    assert {:reply, result, _state} = get_token("key", state)
    assert match?({:local, _token}, result) or match?({:remote, _token, _node}, result)
  end
end
