defmodule Mind.Cluster.Monitor do
  use GenServer

  alias Mind.Config
  alias __MODULE__.State

  def child_spec(opts) do
    id = Keyword.fetch!(opts, :id)
    %{id: __MODULE__, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id),
    do: GenServer.start_link(__MODULE__, id, name: via(id))

  def subscribe(id, pid \\ self()),
    do: GenServer.cast(via(id), {:subscribe, pid})

  def init(id) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    nodes = [Node.self() | Node.list()]

    {:ok, State.new(id, nodes)}
  end

  def handle_cast({:subscribe, pid}, state) do
    ref = Process.monitor(pid)
    new_state = State.add_subscriptor(state, pid, ref)

    state
    |> State.nodes()
    |> Enum.each(&notify_node_added(pid, &1))

    {:noreply, new_state}
  end

  def handle_info({:node_up, node}, state) do
    case State.node_up(state, node) do
      {:recovered, timer_ref, new_state} ->
        Process.cancel_timer(timer_ref)

        {:noreply, new_state}

      {:new, new_state} ->
        state
        |> State.subscriptors()
        |> Enum.each(&notify_node_added(&1, node))

        {:noreply, new_state}
    end
  end

  def handle_info({:node_down, node}, %{id: id} = state) do
    timeout = Config.Store.node_timeout_ms(id)

    ref = Process.send_after(self(), {:node_timeout, node}, timeout)
    new_state = State.node_down(state, node, ref)

    {:noreply, new_state}
  end

  def handle_info({:node_timeout, node}, state) do
    case State.node_timeout(state, node) do
      {:ok, new_state} ->
        state
        |> State.subscriptors()
        |> Enum.each(&notify_node_removed(&1, node))

        {:noreply, new_state}

      :not_found ->
        {:noreply, state}
    end
  end

  def handle_info({:DOWN, ref, _, _, _}, state) do
    new_state = State.remove_subscriptor(state, ref)

    {:noreply, new_state}
  end

  defp notify_node_added(pid, node),
    do: send(pid, {:node_added, node})

  defp notify_node_removed(pid, node),
    do: send(pid, {:node_removed, node})

  defp via(id),
    do: Mind.Registry.via(id, __MODULE__)
end
