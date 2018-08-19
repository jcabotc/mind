defmodule Mind.Config.Store do
  use GenServer

  def child_spec(opts) do
    config = Keyword.fetch!(opts, :config)

    %{id: __MODULE__, start: {__MODULE__, :start_link, [config]}}
  end

  def start_link(%{id: id} = config),
    do: GenServer.start_link(__MODULE__, config, name: via(id))

  def key_replicas(id),
    do: GenServer.call(via(id), {:field, :key_replicas})

  def write_quorum(id),
    do: GenServer.call(via(id), {:field, :write_quorum})

  def read_quorum(id),
    do: GenServer.call(via(id), {:field, :read_quorum})

  def init(config),
    do: {:ok, %{config: config}}

  def handle_call({:field, field}, _from, %{config: config} = state),
    do: {:reply, Map.fetch!(config, field), state}

  defp via(id),
    do: Mind.Registry.via(id, __MODULE__)
end
