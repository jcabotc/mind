defmodule Mind.Store.RegistryTest do
  use ExUnit.Case, async: true

  alias Mind.Store.Registry
  @name __MODULE__

  test "register and fetch" do
    {:ok, _registry} = start_supervised({Registry, name: @name})

    id = 1234
    assert :not_found == Registry.fetch(@name, id)

    via_tuple = Registry.via_tuple(@name, id)
    {:ok, pid} = Agent.start_link(fn -> :ok end, name: via_tuple)

    assert {:ok, pid} == Registry.fetch(@name, id)
  end
end
