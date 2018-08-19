defmodule Mind.RemoteTest do
  use ExUnit.Case, async: true

  alias Mind.Remote

  defmodule TestMod do
    def test_fun(arg), do: {:called, arg}
  end

  @id __MODULE__

  test "run/2" do
    {:ok, _pid} = start_supervised({Remote.Caller.Supervisor, id: @id})
    {:ok, _pid} = start_supervised({Remote.Runner.Supervisor, id: @id})

    self_node = Node.self()

    request = %Remote.Request{
      nodes: [self_node, self_node],
      mfa: {TestMod, :test_fun, ["foo"]},
      quorum: 2,
      timeout_ms: 1000
    }

    results = [{:called, "foo"}, {:called, "foo"}]
    assert {:ok, results} == Remote.run(@id, request)
  end
end
