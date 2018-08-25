defmodule Mind.Cluster.State.Timeouts do
  alias __MODULE__

  defstruct refs: %{},
            nodes: %{}

  def new(),
    do: %Timeouts{}

  def add(%Timeouts{refs: refs, nodes: nodes} = timeouts, node, ref) do
    new_refs = Map.put(refs, node, ref)
    new_nodes = Map.put(nodes, ref, node)

    %{timeouts | refs: new_refs, nodes: new_nodes}
  end

  def pop_by_ref(%Timeouts{refs: refs, nodes: nodes} = timeouts, ref) do
    case Map.pop(nodes, ref) do
      {nil, ^nodes} ->
        :not_found

      {node, new_nodes} ->
        new_refs = Map.delete(refs, node)
        new_timeouts = %{timeouts | refs: new_refs, nodes: new_nodes}
        {:ok, node, new_timeouts}
    end
  end

  def pop_by_node(%Timeouts{refs: refs, nodes: nodes} = timeouts, node) do
    case Map.pop(refs, node) do
      {nil, ^refs} ->
        :not_found

      {ref, new_refs} ->
        new_nodes = Map.delete(nodes, ref)
        {:ok, ref, %{timeouts | refs: new_refs, nodes: new_nodes}}
    end
  end

  def remove_by_node(timeouts, node) do
    case pop_by_node(timeouts, node) do
      :not_found -> timeouts
      {:ok, _ref, new_timeouts} -> new_timeouts
    end
  end
end
