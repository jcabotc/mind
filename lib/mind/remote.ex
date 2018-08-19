defmodule Mind.Remote do
  alias __MODULE__.{Request, Caller}

  def run(id, %Request{} = request),
    do: Caller.Supervisor.run(id, request)
end
