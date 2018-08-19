defmodule Mind.Coordinator.Query do
  defstruct [:nodes, :mfa, :quorum, :timeout_ms]

  defdelegate run(id, query),
    to: __MODULE__.Caller
end
