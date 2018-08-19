defmodule Mind.Registry do
  @name __MODULE__

  def child_spec(opts) do
    opts
    |> Keyword.put_new(:name, @name)
    |> Keyword.put(:keys, :unique)
    |> Registry.child_spec()
  end

  def via(registry \\ @name, id, tag),
    do: {:via, Registry, {registry, {id, tag}}}
end
