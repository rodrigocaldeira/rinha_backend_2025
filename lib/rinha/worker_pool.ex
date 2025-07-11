defmodule Rinha.WorkerPool do
  use Supervisor

  require Logger

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    size = Keyword.get(args, :size, 1)
    job = Keyword.get(args, :job)

    Logger.info("Starting worker pool with #{size} workers")

    children =
      Enum.map(1..size, fn i ->
        {Rinha.Worker, name: :"worker_#{i}", job: job}
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
