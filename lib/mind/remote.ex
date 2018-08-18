defmodule Mind.Remote do
  alias __MODULE__.{Request, Caller, Runner}

  def child_specs(opts) do
    remote = Keyword.fetch!(opts, :name)

    caller_sup = get_caller_sup(remote)
    runner_sup = get_runner_sup(remote)

    [
      Runner.Supervisor.child_spec(name: runner_sup),
      Caller.Supervisor.child_spec(runner_sup: runner_sup, name: caller_sup)
    ]
  end

  def run(remote, %Request{} = request) do
    runner_sup = get_runner_sup(remote)

    remote
    |> get_caller_sup()
    |> Caller.Supervisor.run(runner_sup, request)
  end

  defp get_caller_sup(remote),
    do: :"#{remote}.Caller.Supervisor"

  defp get_runner_sup(remote),
    do: :"#{remote}.Runner.Supervisor"
end
