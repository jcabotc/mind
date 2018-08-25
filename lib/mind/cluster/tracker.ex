defmodule Mind.Cluster.Tracker do
  use GenServer

  @node_timeout_ms 1000 * 60 * 60 * 4

  alias Mind.Cluster.{State, Snapshot}

  def child_spec(opts) do
    id = Keyword.fetch!(opts, :id)

    %{id: __MODULE__, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id),
    do: GenServer.start_link(__MODULE__, :ok, name: via(id))

  def snapshot(id, key, replicas),
    do: GenServer.call(via(id), {:snapshot, key, replicas})

  def init(:ok) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    nodes = [Node.self() | Node.list()]

    {:ok, State.new(nodes)}
  end

  def handle_call({:snapshot, key, replicas}, _from, state) do
    nodes =
      state
      |> State.up_nodes_stream(key)
      |> Enum.take(replicas)

    snapshot = %Snapshot{
      key: key,
      nodes: nodes
    }

    {:reply, snapshot, state}
  end

  # TODO: Maybe remove sent_after timeout using its ref
  def handle_info({:node_up, node}, state),
    do: {:noreply, State.node_up(state, node)}

  def handle_info({:node_down, node}, state) do
    ref = Process.send_after(self(), {:node_timeout, node}, @node_timeout_ms)

    {:noreply, State.node_down(state, node, ref)}
  end

  def handle_info({:node_timeout, node}, state),
    do: {:noreply, State.node_timeout(state, node)}

  defp via(id),
    do: Mind.Registry.via(id, __MODULE__)
end
