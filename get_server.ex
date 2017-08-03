defmodule Stack do
  use GenServer

  def start_link(elements) do
    GenServer.start_link(__MODULE__, elements)
  end

  def init(elements) do
    {:ok, elements}
  end

  def push(stack, element) do
    GenServer.cast(stack, {:push, element})
  end

  def pop(stack) do
    GenServer.call(stack, :pop)
  end

  def top(stack) do
    GenServer.call(stack, :top)
  end

  def handle_cast({:push, element}, elements) do
    {:noreply, [element | elements]}
  end

  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  def handle_call(:top, _from, elements = [head | tail]) do
    {:reply, head, elements}
  end

end

{:ok, stack} = Stack.start_link([1, 2, 3])

IO.puts Stack.top(stack) # => 1
IO.puts Stack.pop(stack) # => 1
IO.puts Stack.top(stack) # => 2

Stack.push(stack, 4)

IO.puts Stack.top(stack) # => 4
