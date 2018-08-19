defmodule Mind.Config.Store do
  use GenServer

  def child_spec(opts) do
    config = Keyword.fetch!(opts, :config)

    %{id: __MODULE__, start: {__MODULE__, :start_link, [config]}}
  end

  def start_link(%{id: id} = config),
    do: GenServer.start_link(__MODULE__, config, name: via(id))

  def key_replicas(id),
    do: GenServer.call(via(id), :key_replicas)

  def init(config),
    do: {:ok, %{config: config}}

  def handle_call(:key_replicas, _from, %{config: config} = state),
    do: {:reply, config.key_replicas, state}

  defp via(id),
    do: Mind.Registry.via(id, __MODULE__)
end
