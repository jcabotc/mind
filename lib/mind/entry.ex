defmodule Mind.Entry do
  alias __MODULE__

  defstruct value: nil,
            clock: Entry.Clock.new()

  def new(value),
    do: %Entry{value: value}

  def fork(%Entry{clock: clock} = entry) do
    {clock_1, clock_2} = Entry.Clock.fork(clock)

    entry_1 = %{entry | clock: clock_1}
    entry_2 = %{entry | clock: clock_2}

    {entry_1, entry_2}
  end

  def change(%Entry{clock: clock} = entry, value) do
    new_clock = Entry.Clock.event(clock)

    %{entry | value: value, clock: new_clock}
  end

  def resolve_conflict(%Entry{} = one, %Entry{} = other, merger) do
    case Entry.Clock.compare(one.clock, other.clock) do
      :gt -> one
      :lt -> other
      :concurrent -> merge(one, other, merger)
      :eq -> one
    end
  end

  defp merge(one, other, merger) do
    value = merger.(one.value, other.value)

    other_history = Entry.Clock.peek(other.clock)
    clock = Entry.Clock.join(one.clock, other_history)

    %Entry{value: value, clock: clock}
  end
end
