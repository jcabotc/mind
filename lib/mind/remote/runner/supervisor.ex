defmodule Mind.Remote.Runner.Supervisor do
  alias Mind.Remote.Runner

  def child_spec(opts) do
    id = Keyword.fetch!(opts, :id)

    %{id: __MODULE__, start: {__MODULE__, :start_link, [id]}}
  end

  def start_link(id),
    do: Task.Supervisor.start_link(name: name(id))

  def run(id, node, mfa, caller_pid) do
    remote_sup = {name(id), node}
    args = [mfa, caller_pid]

    Task.Supervisor.start_child(remote_sup, Runner, :run, args)
  end

  defp name(id),
    do: :"#{id}.Remote.Runner.Supervisor"
end
