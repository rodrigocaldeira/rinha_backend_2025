defmodule Rinha.Queue do
  use GenServer

  @impl true
  def init(_), do: {:ok, []}

  def start_link(defaults) do
    GenServer.start_link(__MODULE__, defaults, name: Queue)
  end

  def enqueue(message), do: GenServer.cast(Queue, {:enqueue, message})

  def dequeue, do: GenServer.call(Queue, :dequeue, :infinity)

  @impl true
  def handle_cast({:enqueue, message}, state) do
    {:noreply, state ++ [message]}
  end

  @impl true
  def handle_call(:dequeue, from, state) do
    Process.send(Queue, {:reply, from}, [])
    {:noreply, state}
  end

  @impl true
  def handle_info({:reply, from}, []) do
    Process.send_after(Queue, {:reply, from}, 100)
    {:noreply, []}
  end

  def handle_info({:reply, from}, [message | rest]) do
    GenServer.reply(from, message)
    {:noreply, rest}
  end

  @impl true
  def handle_continue(message, state) do
    IO.inspect(message)
    {:noreply, state}
  end
end
