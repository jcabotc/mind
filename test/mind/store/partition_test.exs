defmodule Mind.Store.PartitionTest do
  use ExUnit.Case, async: true

  alias Mind.Store.Partition

  test "fetch and put" do
    {:ok, pid} = start_supervised(Partition)

    assert :ok == Partition.put(pid, :foo, "foo")

    assert {:ok, "foo"} == Partition.fetch(pid, :foo)
    assert :not_found == Partition.fetch(pid, :bar)
  end
end
