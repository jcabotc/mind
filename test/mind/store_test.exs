defmodule Mind.StoreTest do
  use ExUnit.Case, async: true

  alias Mind.Store

  test "fetch and put" do
    {:ok, pid} = start_supervised(Store)

    assert :ok == Store.put(pid, :foo, "foo")

    assert {:ok, "foo"} == Store.fetch(pid, :foo)
    assert :not_found == Store.fetch(pid, :bar)
  end
end
