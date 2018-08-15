defmodule Mind.Cluster.Members do
  alias __MODULE__

  @type status :: :up | :down | :unknown
  @type statuses :: %{node => status}

  @type t :: %__MODULE__{
          statuses: statuses
        }

  defstruct statuses: %{}

  defguard is_status(status) when status in [:up, :down]

  def new(),
    do: %Members{}

  def new(nodes, status) when is_status(status),
    do: Enum.reduce(nodes, new(), &set(&2, &1, :up))

  def set(%Members{statuses: statuses} = members, node, status) when is_status(status),
    do: %{members | statuses: Map.put(statuses, node, status)}

  def delete(%Members{statuses: statuses} = members, node),
    do: %{members | statuses: Map.delete(statuses, node)}

  def status(%Members{statuses: statuses}, node),
    do: Map.get(statuses, node, :unknown)
end
