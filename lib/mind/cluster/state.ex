defmodule Mind.Cluster.State do
  alias __MODULE__.{Members, Ring, Timeouts}

  defstruct ring: nil,
            members: nil,
            timeouts: Timeouts.new()

  def new(initial_nodes) do
    ring = Ring.new(initial_nodes)
    members = Members.new(initial_nodes, :up)

    %__MODULE__{ring: ring, members: members}
  end

  def up_nodes_stream(%{ring: ring, members: members}, key) do
    ring
    |> Ring.key_stream(key)
    |> Stream.filter(&(Members.status(members, &1) == :up))
  end

  def node_up(state, node) do
    state
    |> Map.update!(:ring, &Ring.add(&1, node))
    |> Map.update!(:members, &Members.set(&1, node, :up))
    |> Map.update!(:timeouts, &Timeouts.remove_by_node(&1, node))
  end

  def node_down(state, node, timeout_ref) do
    state
    |> Map.update!(:members, &Members.set(&1, node, :down))
    |> Map.update!(:timeouts, &Timeouts.add(&1, node, timeout_ref))
  end

  def node_timeout(state, node) do
    state
    |> Map.update!(:ring, &Ring.remove(&1, node))
    |> Map.update!(:members, &Members.delete(&1, node))
    |> Map.update!(:timeouts, &Timeouts.remove_by_node(&1, node))
  end
end
