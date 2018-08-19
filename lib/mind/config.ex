defmodule Mind.Config do
  @type id :: atom
  @type key_replicas :: pos_integer

  @type t :: %__MODULE__{
          id: id,
          key_replicas: key_replicas
        }

  defstruct id: Mind,
            key_replicas: 3
end
