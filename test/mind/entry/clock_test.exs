defmodule Mind.Entry.ClockTest do
  use ExUnit.Case, async: true

  alias Mind.Entry.Clock

  test "everything" do
    clock = Clock.new()
    {clock_1, clock_2} = Clock.fork(clock)
    assert :eq = Clock.compare(clock_1, clock_2)

    clock_1_1 = Clock.event(clock_1)
    assert :gt = Clock.compare(clock_1_1, clock_2)

    clock_2_1 = Clock.event(clock_2)
    assert :concurrent = Clock.compare(clock_1_1, clock_2_1)

    {clock_2_1_1, clock_2_1_2} = Clock.fork(clock_2_1)
    clock_3 = Clock.join(clock_1_1, clock_2_1_1)
    assert :lt = Clock.compare(clock_2_1_2, clock_3)
  end
end
