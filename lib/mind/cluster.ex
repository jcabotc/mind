defmodule Mind.Cluster do
  use GenServer

  alias __MODULE__.{Ring, Events}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    ring = build_ring()

    {:ok, %{ring: ring}}
  end

  def handle_info({:node_up, new_node}, %{ring: ring} = state) do
    new_ring = Ring.add(ring, new_node)
    :ok = Events.notify({:node_added, new_node})

    {:noreply, %{state | ring: new_ring}}
  end

  def handle_info({:node_down, dead_node}, %{ring: ring} = state) do
    new_ring = Ring.remove(ring, dead_node)
    :ok = Events.notify({:node_removed, dead_node})

    {:noreply, %{state | ring: new_ring}}
  end

  defp build_ring() do
    nodes = Node.list()
    ring = Ring.new()

    Enum.reduce(nodes, ring, &Ring.add(&2, &1))
  end
end
