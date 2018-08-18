defmodule Mind.RemoteTest do
  use ExUnit.Case, async: true

  alias Mind.Remote

  defmodule TestMod do
    def test_fun(arg), do: {:called, arg}
  end

  @name __MODULE__

  test "run/2" do
    [name: @name]
    |> Remote.child_specs()
    |> Enum.each(&start_supervised/1)

    self_node = Node.self()

    request = %Remote.Request{
      nodes: [self_node, self_node],
      mfa: {TestMod, :test_fun, ["foo"]},
      quorum: 2,
      timeout_ms: 1000
    }

    results = [{:called, "foo"}, {:called, "foo"}]
    assert {:ok, results} == Remote.run(@name, request)
  end
end
