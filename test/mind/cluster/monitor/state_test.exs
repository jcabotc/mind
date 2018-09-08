defmodule Mind.Cluster.Monitor.StateTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster.Monitor.State

  @id __MODULE__

  defp same_items?(one, other),
    do: Enum.sort(one) == Enum.sort(other)

  describe "node-related functions" do
    test "up, down, and timeout" do
      state = State.new(@id, [:node_1])
      assert State.nodes(state) == [:node_1]

      assert {:new, state} = State.node_up(state, :node_2)
      assert same_items?(State.nodes(state), [:node_1, :node_2])

      state = State.node_down(state, :node_2, :ref_2)
      assert same_items?(State.nodes(state), [:node_1, :node_2])

      assert {:ok, state} = State.node_timeout(state, :node_2)
      assert State.nodes(state) == [:node_1]

      assert :not_found = State.node_timeout(state, :node_2)
    end

    test "down, and up again" do
      state = State.new(@id, [:node_1])
      state = State.node_down(state, :node_1, :ref_1)

      assert {:recovered, :ref_1, state} = State.node_up(state, :node_1)
      assert [:node_1] == State.nodes(state)
    end
  end

  test "subscriptor-related functions" do
    state = State.new(@id, [])
    assert State.subscriptors(state) == []

    state =
      state
      |> State.add_subscriptor(:pid_1, :ref_1)
      |> State.add_subscriptor(:pid_2, :ref_2)
    assert same_items?(State.subscriptors(state), [:pid_1, :pid_2])

    state = State.remove_subscriptor(state, :ref_2)
    assert State.subscriptors(state) == [:pid_1]
  end
end
