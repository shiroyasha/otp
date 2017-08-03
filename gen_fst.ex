defmodule Lock do

  #
  # Public interface
  #

  def start_link(options) do
    :gen_fsm.start_link(__MODULE__, options, [])
  end

  def lock(lock, password) do
    :gen_fsm.sync_send_event(lock, {:lock, password})
  end

  def unlock(lock, password) do
    :gen_fsm.sync_send_event(lock, {:unlock, password})
  end

  def state(lock) do
    :gen_fsm.sync_send_event(lock, :state)
  end

  #
  # Internal server interface
  #

  def init(password: password) do
    state_data = %{
      unlock_attempts: 0,
      password: password
    }

    {:ok, :unlocked, state_data}
  end

  def unlocked(:state, _from, state_data) do
    {:reply, :unlocked, :unlocked, state_data}
  end

  def unlocked({:lock, password}, _from, state_data) do
    if password == state_data.password do
      {:reply, :ok, :locked, state_data}
    else
      reply = {:error, "Not locked"}
      {:reply, reply, :unlocked, state_data}
    end
  end

  def locked(:state, _from, state_data) do
    {:reply, :locked, :locked, state_data}
  end

  def locked({:unlock, password}, _from, state_data) do
    if password == state_data.password do
      {:reply, :ok, :unlocked, state_data}
    else
      new_state_data = %{ state_data | unlock_attempts: state_data.unlock_attempts + 1}
      reply = {:error, "Wrong password"}

      {:reply, reply, :locked, new_state_data}
    end
  end

  def locked({:lock, password}, _from, state_data) do
    reply = {:error, "Already locked"}

    {:reply, reply, :locked, state_data}
  end

end


{:ok, lock} = Lock.start_link(password: "test")

IO.puts Lock.state(lock) # => unlocked

Lock.lock(lock, "test")

IO.puts Lock.state(lock) # => locked

Lock.lock(lock, "test")
Lock.lock(lock, "test")

IO.puts Lock.state(lock) # => locked

IO.inspect Lock.unlock(lock, "test")

IO.puts Lock.state(lock) # => unlocked
