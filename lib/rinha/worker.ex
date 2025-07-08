defmodule Rinha.Worker do
  use GenServer

  @impl true
  def init(_), do: {:ok, [], {:continue, :process_message}}

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: Worker)
  end

  @impl true
  def handle_continue(:process_message, _) do
    payment = Rinha.Queue.dequeue()
    Rinha.pay(payment)
    {:noreply, [], {:continue, :process_message}}
  end
end
