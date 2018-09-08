defmodule Mind.Cluster.Monitor.State.Timeouts do
  defstruct refs: %{},
            nodes: %{}

  def new(),
    do: %__MODULE__{}

  def put(%{refs: refs, nodes: nodes} = timeouts, node, ref) do
    new_refs = Map.put(refs, node, ref)
    new_nodes = Map.put(nodes, ref, node)

    %{timeouts | refs: new_refs, nodes: new_nodes}
  end

  def pop(%{refs: refs, nodes: nodes} = timeouts, node) do
    case Map.pop(refs, node) do
      {nil, ^refs} ->
        :not_found

      {ref, new_refs} ->
        new_nodes = Map.delete(nodes, ref)
        {:ok, ref, %{timeouts | refs: new_refs, nodes: new_nodes}}
    end
  end
end
