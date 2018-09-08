defmodule Mind.Config do
  @type id :: atom
  @type key_replicas :: pos_integer
  @type quorum :: pos_integer
  @type node_timeout_ms :: non_neg_integer

  @type t :: %__MODULE__{
          id: id,
          key_replicas: key_replicas,
          read_quorum: quorum,
          write_quorum: quorum,
          node_timeout_ms: node_timeout_ms
        }

  @default_id Mind

  defstruct id: @default_id,
            key_replicas: 3,
            read_quorum: 1,
            write_quorum: 1,
            node_timeout_ms: 1000 * 60 * 5

  def default_id(),
    do: @default_id
end
