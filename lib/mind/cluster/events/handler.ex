defmodule Mind.Cluster.Events.Handler do
  use GenServer, restart: :temporary

  def start_link(callback) do
    GenServer.start_link(__MODULE__, callback)
  end

  def notify(pid, event) do
    GenServer.cast(pid, {:notify, event})
  end

  def init(callback) do
    {:ok, %{callback: callback}}
  end

  def handle_cast({:notify, event}, %{callback: callback} = state) do
    case callback.(event) do
      :ok -> {:noreply, state}
      {:error, reason} -> {:stop, reason, state}
    end
  end
end
