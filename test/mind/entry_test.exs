defmodule Mind.EntryTest do
  use ExUnit.Case, async: true

  alias Mind.Entry

  test "all functions" do
    entry = Entry.new(:foo)
    {entry_a_1, entry_b_1} = Entry.fork(entry)

    entry_a_2 = Entry.change(entry_a_1, :bar)
    entry_b_2 = Entry.change(entry_b_1, :baz)

    merger = fn _, _ -> raise "merger_called" end
    assert entry_a_2 == Entry.resolve_conflict(entry_a_2, entry_b_1, merger)
    assert entry_a_2 == Entry.resolve_conflict(entry_b_1, entry_a_2, merger)

    merger = &{&1, &2}
    entry_ab_1 = Entry.resolve_conflict(entry_a_2, entry_b_2, merger)
    assert entry_ab_1.value == {:bar, :baz}

    merger = fn _, _ -> raise "merger_called" end
    assert entry_ab_1 == Entry.resolve_conflict(entry_ab_1, entry_b_2, merger)
    assert entry_ab_1 == Entry.resolve_conflict(entry_ab_1, entry_a_1, merger)
    assert entry_ab_1 == Entry.resolve_conflict(entry_ab_1, entry, merger)
  end
end
