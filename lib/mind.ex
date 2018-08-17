defmodule Mind do
  @name __MODULE__

  def child_spec(opts) do
    opts
    |> fill_opts()
    |> Mind.Supervisor.start_link()
  end

  def start_link(opts) do
    opts
    |> fill_opts()
    |> Mind.Supervisor.start_link()
  end

  defp fill_opts(opts) do
    name = Keyword.get(opts, :name, @name)

    store = get_store(name)
    cluster = get_cluster(name)

    opts
    |> Keyword.put_new(:name, name)
    |> Keyword.put(:store_name, store)
    |> Keyword.put(:cluster_name, cluster)
  end

  defp get_cluster(name),
    do: :"#{name}.Cluster"

  defp get_store(name),
    do: :"#{name}.Store"
end
