defmodule Mind.Store do
  use GenServer

  def child_specs(opts),
    do: [child_spec(opts)]

  def start_link(opts),
    do: GenServer.start_link(__MODULE__, :ok, opts)

  def fetch(store, key),
    do: GenServer.call(store, {:fetch, key})

  def put(store, key, value),
    do: GenServer.call(store, {:put, key, value})

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
