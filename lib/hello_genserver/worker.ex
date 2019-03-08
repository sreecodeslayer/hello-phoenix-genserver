defmodule HelloGenserver.Worker do
  use GenServer

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
    IO.puts("GenServer is now running on: ")
    IO.inspect(Node.self())
    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    # In 2 minute
    Process.send_after(self(), :work, 2 * 60 * 1000)
  end
end
