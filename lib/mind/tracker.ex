defmodule Mind.Tracker do
  use GenServer

  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)

    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    nodes = Node.list()

    state = %{nodes: nodes}
    {:ok, state}
  end

  def handle_info({:node_up, new_node}, %{nodes: nodes} = state) do
    new_nodes = [new_node | nodes]

    {:noreply, %{state | nodes: new_nodes}}
  end

  def handle_info({:node_down, dead_node}, %{nodes: nodes} = state) do
    new_nodes = List.delete(nodes, dead_node)

    {:noreply, %{state | nodes: new_nodes}}
  end
end
