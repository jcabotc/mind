defmodule Mind.Cluster.Ring do
  alias __MODULE__

  @multiplicity 100
  @hash_range trunc(:math.pow(2, 32) - 1)

  defstruct tree: :gb_trees.empty(),
            nodes: MapSet.new()

  def new(),
    do: %Ring{}

  def new(nodes),
    do: Enum.reduce(nodes, new(), &add(&2, &1))

  def key_stream(%Ring{nodes: []}, _key),
    do: []

  def key_stream(%Ring{tree: tree, nodes: nodes}, key) do
    key_hash = :erlang.phash2(key, @hash_range)
    num_nodes = MapSet.size(nodes)

    tree
    |> Ring.Iterator.new(key_hash, num_nodes)
    |> Stream.unfold(&Ring.Iterator.next/1)
  end

  def add(%Ring{tree: tree, nodes: nodes} = ring, node) do
    case MapSet.member?(nodes, node) do
      true ->
        ring

      false ->
        new_tree = add_tokens(tree, node)
        new_nodes = MapSet.put(nodes, node)

        %{ring | tree: new_tree, nodes: new_nodes}
    end
  end

  defp add_tokens(tree, node) do
    Enum.reduce(1..@multiplicity, tree, fn i, tree ->
      token = :erlang.phash2({node, i}, @hash_range)

      try do
        :gb_trees.insert(token, node, tree)
      catch
        :error, {:key_exists, ^token} -> solve_conflict(tree, token, node)
      end
    end)
  end

  defp solve_conflict(tree, token, new_node) do
    {:value, old_node} = :gb_trees.lookup(token, tree)

    case old_node < new_node do
      true -> tree
      false -> :gb_trees.update(token, new_node, tree)
    end
  end

  def remove(%Ring{tree: tree, nodes: nodes} = ring, node) do
    case MapSet.member?(nodes, node) do
      true ->
        new_tree = remove_tokens(tree, node)
        new_nodes = MapSet.delete(nodes, node)

        %{ring | tree: new_tree, nodes: new_nodes}

      false ->
        ring
    end
  end

  defp remove_tokens(tree, node) do
    tree
    |> :gb_trees.to_list()
    |> Enum.reject(&match?({_token, ^node}, &1))
    |> :gb_trees.from_orddict()
  end
end
