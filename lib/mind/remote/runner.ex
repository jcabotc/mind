defmodule Mind.Remote.Runner do
  def run({mod, fun, args}, caller_pid) do
    result = apply(mod, fun, args)

    send(caller_pid, {:done, result})
  end
end
