defmodule HelloGenserver.Worker do
  use GenServer
  require Logger

  def start_link(worker_name) do
    GenServer.start_link(__MODULE__, [worker_name])
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start

    schedule_work()

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    # Do the desired work here
    # Print out the node IP here
    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  # Swarm state handlers

  # called when a handoff has been initiated due to changes
  # in cluster topology, valid response values are:
  #
  #   - `:restart`, to simply restart the process on the new node
  #   - `{:resume, state}`, to hand off some state to the new process
  #   - `:ignore`, to leave the process running on its current node
  #
  @impl true
  def handle_call({:swarm, :begin_handoff}, _from, {name, delay}) do
    {:reply, {:resume, delay}, {name, delay}}
  end

  # called after the process has been restarted on its new node,
  # and the old process' state is being handed off. This is only
  # sent if the return to `begin_handoff` was `{:resume, state}`.
  # **NOTE**: This is called *after* the process is successfully started,
  # so make sure to design your processes around this caveat if you
  # wish to hand off state like this.
  @impl true
  def handle_cast({:swarm, :end_handoff, delay}, {name, _}) do
    {:noreply, {name, delay}}
  end

  # called when a network split is healed and the local process
  # should continue running, but a duplicate process on the other
  # side of the split is handing off its state to us. You can choose
  # to ignore the handoff state, or apply your own conflict resolution
  # strategy
  def handle_cast({:swarm, :resolve_conflict, _delay}, state) do
    {:noreply, state}
  end

  # this message is sent when this process should die
  # because it is being moved, use this as an opportunity
  # to clean up
  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end

  defp schedule_work do
    # In 30 seconds
    whereami()
    Process.send_after(self(), :work, 30 * 1000)
  end

  defp whereami do
    Logger.debug("GenServer is now running on: #{Node.self()}")
    Logger.debug("Am also connected now to dudes => #{inspect(Node.list())}")
  end
end
