defmodule Mind.Coordinator.QueryTest do
  use ExUnit.Case, async: true

  alias Mind.Coordinator.Query

  defmodule TestMod do
    def test_fun(arg), do: {:called, arg}
  end

  @id __MODULE__

  test "run/2" do
    {:ok, _pid} = start_supervised({Query.Caller, id: @id})
    {:ok, _pid} = start_supervised({Query.Runner, id: @id})

    self_node = Node.self()

    query = %Query{
      nodes: [self_node, self_node],
      mfa: {TestMod, :test_fun, ["foo"]},
      quorum: 2,
      timeout_ms: 1000
    }

    results = [{:called, "foo"}, {:called, "foo"}]
    assert {:ok, results} == Query.run(@id, query)
  end
end
