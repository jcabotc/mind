defmodule Mind.StoreTest do
  use ExUnit.Case, async: true

  alias Mind.Store
  @id __MODULE__

  test "fetch and put" do
    {:ok, _pid} = start_supervised({Store, id: @id})

    assert :ok == Store.put(@id, :foo, "foo")

    assert {:ok, "foo"} == Store.fetch(@id, :foo)
    assert :not_found == Store.fetch(@id, :bar)
  end
end
