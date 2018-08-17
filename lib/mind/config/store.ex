defmodule Mind.Config.Store do
  use GenServer

  def start_link(config, opts),
    do: GenServer.start_link(__MODULE__, config, opts)

  def get(name),
    do: GenServer.call(name, :get)

  def init(config),
    do: {:ok, %{config: config}}

  def handle_call(:get, _from, %{config: config} = state),
    do: {:reply, config, state}
end
