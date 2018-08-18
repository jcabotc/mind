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

    opts
    |> Keyword.put_new(:name, name)
    |> Keyword.put(:store_name, get_store(name))
    |> Keyword.put(:cluster_name, get_cluster(name))
    |> Keyword.put(:remote_name, get_remote(name))
  end

  defp get_cluster(name),
    do: :"#{name}.Cluster"

  defp get_store(name),
    do: :"#{name}.Store"

  defp get_remote(name),
    do: :"#{name}.Remote"
end
