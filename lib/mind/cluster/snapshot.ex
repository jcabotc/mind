defmodule Mind.Cluster.Snapshot do
  @type key :: term

  @type t :: %__MODULE__{
          key: key,
          nodes: [node]
        }

  defstruct [:key, :nodes]
end
