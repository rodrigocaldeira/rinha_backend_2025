defmodule Rinha.Queue do
  use GenServer

  @impl true
  def init(_), do: {:ok, :queue.new()}

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue, name: Queue)
  end

  def enqueue(message), do: GenServer.cast(Queue, {:enqueue, message})

  def dequeue, do: GenServer.call(Queue, :dequeue, :infinity)

  @impl true
  def handle_cast({:enqueue, message}, queue) do
    queue = :queue.in(message, queue)
    {:noreply, queue}
  end

  @impl true
  def handle_call(:dequeue, from, queue) do
    Process.send(Queue, {:reply, from}, [])
    {:noreply, queue}
  end

  @impl true
  def handle_info({:reply, from}, {[], []}) do
    Process.send(Queue, {:reply, from}, [])
    {:noreply, {[], []}}
  end

  def handle_info({:reply, from}, queue) do
    {{:value, message}, queue} = :queue.out(queue)
    GenServer.reply(from, message)
    {:noreply, queue}
  end
end
