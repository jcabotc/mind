defmodule Mind.ClusterTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster

  defp get_nodes(key, limit, state),
    do: Cluster.handle_call({:nodes, key, limit}, :from, state)

  defp node_up(node, state),
    do: Cluster.handle_info({:node_up, node}, state)

  defp node_down(node, state),
    do: Cluster.handle_info({:node_down, node}, state)

  defp node_timeout(node, state),
    do: Cluster.handle_info({:node_timeout, node}, state)

  @events_name :"#{__MODULE__}_events"

  test "handle_* functions" do
    current_node = Node.self()
    test_pid = self()

    {:ok, events} = start_supervised({Cluster.Events, name: @events_name})

    callback = fn event ->
      send(test_pid, {:notified, event})
      :ok
    end

    assert {:ok, _pid} = Cluster.Events.subscribe(events, callback)

    assert {:ok, state} = Cluster.init(events)
    assert_receive {:notified, {:node_added, ^current_node}}

    assert {:reply, nodes, state} = get_nodes("key", 2, state)
    assert [current_node] == nodes

    assert {:noreply, state} = node_up(:node_1, state)
    assert {:noreply, state} = node_up(:node_2, state)
    assert_receive {:notified, {:node_added, :node_1}}
    assert_receive {:notified, {:node_added, :node_2}}

    assert {:reply, nodes, state} = get_nodes("key", 2, state)
    unique_nodes = Enum.uniq(nodes)
    assert Enum.count(unique_nodes) == 2
    assert Enum.all?(nodes, &(&1 in [current_node, :node_1, :node_2]))

    assert {:noreply, state} = node_down(:node_1, state)

    assert {:reply, nodes, state} = get_nodes("key", 2, state)
    assert Enum.sort(nodes) == Enum.sort([current_node, :node_2])

    assert {:noreply, _state} = node_timeout(:node_1, state)
    assert_receive {:notified, {:node_removed, :node_1}}
  end
end
