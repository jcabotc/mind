defmodule Mind.Cluster.MonitorTest do
  use ExUnit.Case, async: true

  alias Mind.{Config, Cluster.Monitor}

  @id __MODULE__
  @config %Config{id: @id}

  defmodule Redirector do
    use GenServer

    def start_link(test_pid),
      do: GenServer.start_link(__MODULE__, test_pid)

    def stop(pid),
      do: GenServer.stop(pid)

    def init(test_pid),
      do: {:ok, test_pid}

    def handle_info(message, test_pid) do
      send(test_pid, {:redirected, message})
      {:noreply, test_pid}
    end
  end

  def start_config_store(config),
    do: {:ok, _pid} = start_supervised({Config.Store, config: config})

  test "subscriptions" do
    current_node = Node.self()

    start_config_store(@config)
    {:ok, pid} = start_supervised({Monitor, id: @id})

    assert :ok = Monitor.subscribe(@id)
    assert_receive {:node_added, ^current_node}

    {:ok, redirector} = Redirector.start_link(self())
    assert :ok = Monitor.subscribe(@id, redirector)
    assert_receive {:redirected, {:node_added, ^current_node}}

    assert send(pid, {:node_up, :node_1})
    assert_receive {:node_added, :node_1}
    assert_receive {:redirected, {:node_added, :node_1}}

    :ok = Redirector.stop(redirector)
    assert send(pid, {:node_up, :node_2})
    assert_receive {:node_added, :node_2}
  end

  test "node down and up again" do
    current_node = Node.self()

    start_config_store(%{@config | node_timeout_ms: 100000})
    {:ok, pid} = start_supervised({Monitor, id: @id})

    assert :ok = Monitor.subscribe(@id)
    assert_receive {:node_added, ^current_node}

    send(pid, {:node_up, :node_1})
    assert_receive {:node_added, :node_1}

    send(pid, {:node_down, :node_1})
    send(pid, {:node_up, :node_1})
    refute_receive {:node_removed, :node_1}, 5
    refute_receive {:node_added, :node_1}, 5
  end

  test "node down and timeout" do
    current_node = Node.self()

    start_config_store(%{@config | node_timeout_ms: 0})
    {:ok, pid} = start_supervised({Monitor, id: @id})

    assert :ok = Monitor.subscribe(@id)
    assert_receive {:node_added, ^current_node}

    send(pid, {:node_up, :node_1})
    assert_receive {:node_added, :node_1}

    send(pid, {:node_down, :node_1})
    assert_receive {:node_removed, :node_1}
  end
end
