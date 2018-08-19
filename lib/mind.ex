defmodule Mind do
  def child_spec(config),
    do: Mind.Supervisor.child_spec(config)

  def start_link(config),
    do: Mind.Supervisor.start_link(config)
end
