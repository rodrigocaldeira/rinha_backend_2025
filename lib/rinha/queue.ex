defmodule Rinha.Queue do
  use GenServer

  @empty_queue :queue.new()

  @impl true
  def init(_), do: {:ok, {@empty_queue, @empty_queue}}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: Queue)
  end

  def enqueue(item), do: send(Queue, {:enqueue, item})

  def dequeue, do: GenServer.call(Queue, :dequeue, :infinity)

  @impl true
  def handle_call(:dequeue, worker, {items, workers}) do
    {:noreply, {items, :queue.in(worker, workers)}, {:continue, :dequeue}}
  end

  @impl true
  def handle_info({:enqueue, item}, {items, workers}) do
    items = :queue.in(item, items)

    {:noreply, {items, workers}, {:continue, :dequeue}}
  end

  @impl true
  def handle_continue(:dequeue, {@empty_queue, _workers} = state) do
    {:noreply, state}
  end

  def handle_continue(:dequeue, {_items, @empty_queue} = state) do
    {:noreply, state}
  end

  def handle_continue(:dequeue, {items, workers}) do
    {{:value, item}, items} = :queue.out(items)
    {{:value, worker}, workers} = :queue.out(workers)

    GenServer.reply(worker, item)
    {:noreply, {items, workers}, {:continue, :dequeue}}
  end
end
