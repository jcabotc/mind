defmodule Mind.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)

    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      Mind.Partition,
      Mind.Tracker
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
