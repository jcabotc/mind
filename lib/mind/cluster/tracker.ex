defmodule Mind.Cluster.Tracker do
  use GenServer

  @node_timeout_ms 1000 * 60 * 60 * 4

  alias Mind.Cluster.{Members, Ring, Timeouts, Events}

  def start_link(events, opts),
    do: GenServer.start_link(__MODULE__, events, opts)

  def nodes(server, key, limit),
    do: GenServer.call(server, {:nodes, key, limit})

  def token(server, key),
    do: GenServer.call(server, {:token, key})

  def init(events) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    nodes = [Node.self() | Node.list()]

    state = %{
      ring: Ring.new(nodes),
      members: Members.new(nodes, :up),
      timeouts: Timeouts.new(),
      events: events
    }

    Enum.each(nodes, &notify_node_added(state, &1))
    {:ok, state}
  end

  def handle_call({:token, key}, _from, %{ring: ring} = state) do
    {token, node} = Ring.token(ring, key)

    case node == Node.self() do
      true -> {:reply, {:local, token}, state}
      false -> {:reply, {:remote, token, node}, state}
    end
  end

  def handle_call({:nodes, key, limit}, _from, state) do
    %{ring: ring, members: members} = state

    nodes =
      ring
      |> Ring.key_stream(key)
      |> Stream.filter(&(Members.status(members, &1) == :up))
      |> Enum.take(limit)

    {:reply, nodes, state}
  end

  def handle_info({:node_up, node}, state) do
    new_state =
      state
      |> Map.update!(:ring, &Ring.add(&1, node))
      |> Map.update!(:members, &Members.set(&1, node, :up))
      |> Map.update!(:timeouts, &Timeouts.remove_by_node(&1, node))

    notify_node_added(state, node)
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

    notify_node_removed(state, node)
    {:noreply, new_state}
  end

  defp notify_node_added(%{events: events}, node),
    do: :ok = Events.notify(events, {:node_added, node})

  defp notify_node_removed(%{events: events}, node),
    do: :ok = Events.notify(events, {:node_removed, node})
end
