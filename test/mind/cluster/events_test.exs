defmodule Mind.Cluster.EventsTest do
  use ExUnit.Case, async: true

  alias Mind.Cluster.Events
  @name __MODULE__

  @tag capture_log: true
  test "subscribe/2 and notify/2" do
    test_pid = self()
    {:ok, pid} = start_supervised({Events, name: @name})

    callback_1 = fn event ->
      send(test_pid, {:callback_1, event})
      :ok
    end

    callback_2 = fn
      :crash -> raise("crash")
      event -> send(test_pid, {:callback_2, event}); :ok
    end

    callback_3 = fn
      :fail -> {:error, :a_reason}
      event -> send(test_pid, {:callback_3, event}); :ok
    end

    assert {:ok, _pid} = Events.subscribe(pid, callback_1)
    assert {:ok, _pid} = Events.subscribe(pid, callback_2)
    assert {:ok, _pid} = Events.subscribe(pid, callback_3)

    assert :ok == Events.notify(pid, :foo)
    assert_receive {:callback_1, :foo}
    assert_receive {:callback_2, :foo}
    assert_receive {:callback_3, :foo}

    assert :ok == Events.notify(pid, :fail)
    assert_receive {:callback_1, :fail}
    assert_receive {:callback_2, :fail}
    refute_receive {:callback_3, :fail}

    assert :ok == Events.notify(pid, :crash)
    assert_receive {:callback_1, :crash}
    refute_receive {:callback_2, :crash}
    refute_receive {:callback_3, :crash}
  end
end
