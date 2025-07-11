defmodule Rinha.Worker do
  use GenServer

  require Logger

  @impl true
  def init(args), do: {:ok, args, {:continue, :execute}}

  def start_link(args) do
    name = Keyword.get(args, :name)
    job = Keyword.get(args, :job)

    Logger.info("Starting worker #{name}")

    GenServer.start_link(__MODULE__, %{job: job}, name: name)
  end

  @impl true
  def handle_continue(:execute, %{job: job} = state) do
    job.()
    {:noreply, state, {:continue, :execute}}
  end

  def child_spec(args) do
    %{
      id: Keyword.get(args, :name, Worker),
      start: {Rinha.Worker, :start_link, [args]}
    }
  end
end
