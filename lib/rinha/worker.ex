defmodule Rinha.Worker do
  use GenServer

  @impl true
  def init(args) do
    Process.send_after(self(), :execute, 0)
    {:ok, args}
  end

  def start_link(args) do
    name = Keyword.get(args, :name)
    job = Keyword.get(args, :job)

    GenServer.start_link(__MODULE__, %{job: job}, name: name)
  end

  @impl true
  def handle_info(:execute, %{job: job} = state) do
    job.()
    Process.send_after(self(), :execute, 1)
    {:noreply, state}
  end

  def child_spec(args) do
    %{
      id: Keyword.get(args, :name, Worker),
      start: {Rinha.Worker, :start_link, [args]}
    }
  end
end
