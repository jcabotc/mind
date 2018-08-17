defmodule Mind.Config do
  @type key_replicas :: pos_integer
  @type read_quorum :: pos_integer
  @type write_quorum :: pos_integer

  @type t :: %__MODULE__{
          key_replicas: key_replicas,
          read_quorum: read_quorum,
          write_quorum: write_quorum
        }

  defstruct [
    key_replicas: 3,
    read_quorum: 1,
    write_quorum: 2
  ]
end
