defmodule Mind do
  alias Mind.{Config, Coordinator}

  @id Config.default_id()

  def child_spec(%Config{} = config),
    do: Mind.Supervisor.child_spec(config)

  def start_link(%Config{} = config),
    do: Mind.Supervisor.start_link(config)

  def fetch(id \\ @id, key) when is_atom(id),
    do: Coordinator.fetch(id, key)

  def put(id \\ @id, key, value) when is_atom(id),
    do: Coordinator.put(id, key, value)
end
