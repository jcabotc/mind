defmodule Mind.Remote.Request do
  defstruct [:nodes, :mfa, :quorum, :timeout_ms]
end
