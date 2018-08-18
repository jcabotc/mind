defmodule Mind.Remote.Runner.Supervisor do
  alias Mind.Remote.Runner

  def child_spec(opts),
    do: %{id: __MODULE__, start: {__MODULE__, :start_link, [opts]}}

  def start_link(opts),
    do: Task.Supervisor.start_link(opts)

  def run(sup, node, mfa, caller_pid) do
    remote_sup = {sup, node}
    args = [mfa, caller_pid]

    Task.Supervisor.start_child(remote_sup, Runner, :run, args)
  end
end
