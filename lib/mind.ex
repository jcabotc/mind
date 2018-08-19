defmodule Mind do
  @name __MODULE__

  def child_spec(config),
    do: Mind.Supervisor.start_child(config)

  def start_link(config),
    do: Mind.Supervisor.start_link(config)
end
