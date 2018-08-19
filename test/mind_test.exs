defmodule MindTest do
  use ExUnit.Case, async: true

  @id __MODULE__

  test "fetch/2 and put/3" do
    config = %Mind.Config{id: @id}
    assert {:ok, _pid} = start_supervised({Mind, config})

    assert :not_found == Mind.fetch(@id, :foo)
    assert :ok == Mind.put(@id, :foo, "foo")
    assert {:ok, "foo"} == Mind.fetch(@id, :foo)
  end
end
