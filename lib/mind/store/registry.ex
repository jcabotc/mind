defmodule Mind.Store.Registry do
  @name __MODULE__

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

  defp fill_opts(opts) do
    opts
    |> Keyword.put_new(:name, @name)
    |> Keyword.put(:keys, :unique)
  end

  def via_tuple(registry \\ @name, id),
    do: {:via, Registry, {registry, id}}

  def fetch(registry \\ @name, id) do
    case Registry.lookup(registry, id) do
      [{pid, _}] -> {:ok, pid}
      [] -> :not_found
    end
  end
end
