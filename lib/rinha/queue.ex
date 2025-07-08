defmodule Rinha.Queue do
  use GenServer

  @impl true
  def init(_), do: {:ok, []}

  def start_link(defaults) do
    GenServer.start_link(__MODULE__, defaults, name: Queue)
  end

  def reset, do: GenServer.call(Queue, :reset)

  def enqueue(message), do: GenServer.cast(Queue, {:enqueue, message})

  def dequeue, do: GenServer.call(Queue, :dequeue, :infinity)

  @impl true
  def handle_call(:reset, _, _) do
    {:reply, :ok, []}
  end

  def handle_call(:dequeue, from, state) do
    Process.send(Queue, {:send_message, from}, [])
    {:noreply, state}
  end

  @impl true
  def handle_info({:send_message, from}, []) do
    Process.send_after(Queue, {:send_message, from}, 100)
    {:noreply, []}
  end

  def handle_info({:send_message, from}, [message | rest]) do
    GenServer.reply(from, message)
    {:noreply, rest}
  end

  @impl true
  def handle_cast({:enqueue, message}, state) do
    {:noreply, state ++ [message]}
  end
end
