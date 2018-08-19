defmodule Mind.Store do
  use GenServer

  def child_spec(opts) do
    id = Keyword.fetch!(opts, :id)

    %{id: __MODULE__, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id),
    do: GenServer.start_link(__MODULE__, :ok, name: via(id))

  def fetch(id, key),
    do: GenServer.call(via(id), {:fetch, key})

  def put(id, key, value),
    do: GenServer.call(via(id), {:put, key, value})

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

  def via(id),
    do: Mind.Registry.via(id, __MODULE__)
end
