defmodule Mind.Config.StoreTest do
  use ExUnit.Case, async: true

  alias Mind.Config
  @id __MODULE__

  test "fetch and put" do
    config = %Config{
      id: @id,
      key_replicas: 4
    }

    {:ok, _pid} = start_supervised({Config.Store, config: config})

    assert Config.Store.key_replicas(@id) == 4
  end
end
