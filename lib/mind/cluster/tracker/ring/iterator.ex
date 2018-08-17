defmodule Mind.Cluster.Tracker.Ring.Iterator do
  alias __MODULE__

  defstruct tree: nil,
            initial: nil,
            source: nil,
            pass: 1,
            returned: MapSet.new(),
            num_nodes: nil

  def new(tree, initial, num_nodes) do
    source = :gb_trees.iterator_from(initial, tree)

    %Iterator{
      tree: tree,
      initial: initial,
      source: source,
      num_nodes: num_nodes
    }
  end

  def next(%{num_nodes: num_nodes, returned: returned} = iter) do
    case MapSet.size(returned) < num_nodes do
      true -> do_next(iter)
      false -> nil
    end
  end

  def do_next(%{pass: 1, source: source} = iter) do
    case :gb_trees.next(source) do
      :none -> start_second_pass(iter)
      {_, node, new_source} -> respond(node, new_source, iter)
    end
  end

  def do_next(%{pass: 2, source: source, initial: initial} = iter) do
    case :gb_trees.next(source) do
      :none -> nil
      {hash, _, _} when hash >= initial -> nil
      {_, node, new_source} -> respond(node, new_source, iter)
    end
  end

  defp start_second_pass(%{tree: tree} = iter) do
    new_source = :gb_trees.iterator(tree)
    new_iter = %{iter | pass: 2, source: new_source}
    do_next(new_iter)
  end

  defp respond(node, new_source, %{returned: returned} = iter) do
    case MapSet.member?(returned, node) do
      true ->
        new_iter = %{iter | source: new_source}
        do_next(new_iter)

      false ->
        new_returned = MapSet.put(returned, node)
        new_iter = %{iter | source: new_source, returned: new_returned}
        {node, new_iter}
    end
  end
end
