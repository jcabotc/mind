defmodule Mind.Partition do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def fetch(server, key) do
    GenServer.call(server, {:fetch, key})
  end

  def put(server, key, value) do
    GenServer.call(server, {:put, key, value})
  end

  def delete(server, key) do
    GenServer.call(server, {:delete, key})
  end

  def init(:ok) do
    {:ok, %{data: %{}}}
  end

  def handle_call({:fetch, key}, _from, %{data: data} = state) do
    case Map.fetch(data, key) do
      {:ok, value} -> {:reply, {:ok, value}, state}
      :error -> {:reply, :not_found, state}
    end
  end

  def handle_call({:put, key, value}, _from, %{data: data} = state) do
    new_data = Map.put(data, key, value)

    {:reply, :ok, %{state | data: new_data}}
  end

  def handle_call({:delete, key}, _from, %{data: data} = state) do
    new_data = Map.delete(data, key)

    {:reply, :ok, %{state | data: new_data}}
  end
end
