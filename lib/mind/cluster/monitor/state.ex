defmodule Mind.Cluster.Monitor.State do
  alias __MODULE__.Timeouts

  defstruct id: nil,
            nodes: [],
            timeouts: Timeouts.new(),
            subscriptors: %{}

  def new(id, nodes) do
    %__MODULE__{id: id, nodes: nodes}
  end

  def nodes(%{nodes: nodes}) do
    nodes
  end

  def node_up(state, node) do
    %{nodes: nodes, timeouts: timeouts} = state

    case Timeouts.pop(timeouts, node) do
      {:ok, ref, new_timeouts} ->
        {:recovered, ref, %{state | timeouts: new_timeouts}}

      :not_found ->
        {:new, %{state | nodes: [node | nodes]}}
    end
  end

  def node_down(%{timeouts: timeouts} = state, node, ref) do
    %{state | timeouts: Timeouts.put(timeouts, node, ref)}
  end

  def node_timeout(state, node) do
    %{nodes: nodes, timeouts: timeouts} = state

    with {:ok, _ref, new_timeouts} <- Timeouts.pop(timeouts, node) do
      new_nodes = List.delete(nodes, node)
      new_state = %{state | nodes: new_nodes, timeouts: new_timeouts}

      {:ok, new_state}
    end
  end

  def subscriptors(%{subscriptors: subscriptors}) do
    Map.values(subscriptors)
  end

  def add_subscriptor(%{subscriptors: subscriptors} = state, pid, ref) do
    %{state | subscriptors: Map.put(subscriptors, ref, pid)}
  end

  def remove_subscriptor(%{subscriptors: subscriptors} = state, ref) do
    %{state | subscriptors: Map.delete(subscriptors, ref)}
  end
end
