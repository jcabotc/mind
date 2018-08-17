defmodule Mind.Store do
  alias __MODULE__.{Registry, Partition}

  def child_specs(opts) do
    store = Keyword.fetch!(opts, :name)

    registry = get_registry(store)
    partition_sup = get_partition_sup(store)

    [
      Registry.child_spec(name: registry),
      Partition.Supervisor.child_spec(name: partition_sup)
    ]
  end

  def start_partition(store, partition_id) do
    name =
      store
      |> get_registry()
      |> Registry.via_tuple(partition_id)

    store
    |> get_partition_sup()
    |> Partition.Supervisor.start_partition(name: name)
  end

  def fetch(store, partition_id, key) do
    store
    |> get_registry()
    |> Registry.via_tuple(partition_id)
    |> Partition.fetch(key)
  end

  def put(store, partition_id, key, value) do
    store
    |> get_registry()
    |> Registry.via_tuple(partition_id)
    |> Partition.put(key, value)
  end

  defp get_registry(store),
    do: :"#{store}.Registry"

  defp get_partition_sup(store),
    do: :"#{store}.Partition.Supervisor"
end
