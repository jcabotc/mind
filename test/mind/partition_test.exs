defmodule Mind.PartitionTest do
  use ExUnit.Case, async: true

  alias Mind.Partition

  test "managing keys and values" do
    {:ok, pid} = Partition.start_link()

    assert :ok = Partition.put(pid, :foo, "FOO")
    assert {:ok, "FOO"} = Partition.fetch(pid, :foo)
    assert :ok = Partition.delete(pid, :foo)
    assert :not_found = Partition.fetch(pid, :foo)
  end
end
