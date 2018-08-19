defmodule Mind.Cluster.Tracker do
  use GenServer

  @node_timeout_ms 1000 * 60 * 60 * 4

  alias __MODULE__.{Members, Ring, Timeouts}
  alias Mind.Cluster.Snapshot

  def start_link(opts),
    do: GenServer.start_link(__MODULE__, :ok, opts)

  def snapshot(server, key),
    do: GenServer.call(server, {:snapshot, key})

  def init(:ok) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    nodes = [Node.self() | Node.list()]

    state = %{
      ring: Ring.new(nodes),
      members: Members.new(nodes, :up),
      timeouts: Timeouts.new(),
    }

    {:ok, state}
  end

  def handle_call({:snapshot, key}, _from, state) do
    %{ring: ring, members: members} = state

    nodes =
      ring
      |> Ring.key_stream(key)
      |> Stream.filter(&(Members.status(members, &1) == :up))
      |> Enum.to_list()

    snapshot = %Snapshot{
      key: key,
      nodes: nodes
    }

    {:reply, snapshot, state}
  end

  def handle_info({:node_up, node}, state) do
    new_state =
      state
      |> Map.update!(:ring, &Ring.add(&1, node))
      |> Map.update!(:members, &Members.set(&1, node, :up))
      |> Map.update!(:timeouts, &Timeouts.remove_by_node(&1, node))

    {:noreply, new_state}
  end

  def handle_info({:node_down, node}, state) do
    ref = Process.send_after(self(), {:node_timeout, node}, @node_timeout_ms)

    new_state =
      state
      |> Map.update!(:members, &Members.set(&1, node, :down))
      |> Map.update!(:timeouts, &Timeouts.add(&1, node, ref))

    {:noreply, new_state}
  end

  def handle_info({:node_timeout, node}, state) do
    new_state =
      state
      |> Map.update!(:ring, &Ring.remove(&1, node))
      |> Map.update!(:members, &Members.delete(&1, node))
      |> Map.update!(:timeouts, &Timeouts.remove_by_node(&1, node))

    {:noreply, new_state}
  end
end
