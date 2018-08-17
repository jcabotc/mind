defmodule Mind.Store.Partition.Supervisor do
  use DynamicSupervisor

  alias Mind.Store.Partition

  def start_link(opts),
    do: DynamicSupervisor.start_link(__MODULE__, :ok, opts)

  def start_partition(sup, opts) do
    spec = Partition.child_spec(opts)

    DynamicSupervisor.start_child(sup, spec)
  end

  def init(:ok),
    do: DynamicSupervisor.init(strategy: :one_for_one)
end
