defmodule HelloGenserver.Worker do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
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

  defp schedule_work do
    # In 30 seconds
    whereami()
    Process.send_after(self(), :work, 30 * 1000)
  end

  defp whereami do
    Logger.info("GenServer is now running on: #{Node.self()}")
    Logger.info("Am also connected now to dudes => #{inspect(Node.list())}")
  end
end
