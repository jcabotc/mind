defmodule Mind.Store.Registry do
  def child_spec(opts) do
    opts
    |> fill_opts()
    |> Registry.child_spec()
  end

  def start_link(opts) do
    opts
    |> fill_opts()
    |> Registry.start_link()
  end

  defp fill_opts(opts),
    do: Keyword.put(opts, :keys, :unique)

  def via_tuple(registry, partition_id),
    do: {:via, Registry, {registry, partition_id}}

  def fetch(registry, partition_id) do
    case Registry.lookup(registry, partition_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> :not_found
    end
  end
end
