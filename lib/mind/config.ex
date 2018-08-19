defmodule Mind.Config do
  @type id :: atom
  @type key_replicas :: pos_integer
  @type quorum :: pos_integer

  @type t :: %__MODULE__{
          id: id,
          key_replicas: key_replicas,
          read_quorum: quorum,
          write_quorum: quorum
        }

  @default_id Mind

  defstruct id: @default_id,
            key_replicas: 3,
            read_quorum: 1,
            write_quorum: 1

  def default_id(),
    do: @default_id
end
