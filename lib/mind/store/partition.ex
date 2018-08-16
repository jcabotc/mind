defmodule Mind.Store.Partition do
  use GenServer

  def start_link(opts),
    do: GenServer.start_link(__MODULE__, :ok, opts)

  def fetch(server, key),
    do: GenServer.call(server, {:fetch, key})

  def put(server, key, value),
    do: GenServer.call(server, {:put, key, value})

  def init(:ok),
    do: {:ok, %{data: %{}}}

  def handle_call({:fetch, key}, _from, %{data: data} = state) do
    case Map.fetch(data, key) do
      {:ok, value} -> {:reply, {:ok, value}, state}
      :error -> {:reply, :not_found, state}
    end
  end

  def handle_call({:put, key, value}, _from, %{data: data} = state) do
    new_state = %{state | data: Map.put(data, key, value)}

    {:reply, :ok, new_state}
  end
end
