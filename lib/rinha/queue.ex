defmodule Rinha.Queue do
  use GenServer

  @impl true
  def init(_), do: {:ok, []}

  def start_link(defaults) do
    GenServer.start_link(__MODULE__, defaults, name: Queue)
  end

  def enqueue(message), do: GenServer.call(Queue, {:enqueue, message})

  def dequeue, do: GenServer.call(Queue, :dequeue, :infinity)

  @impl true
  def handle_call({:enqueue, message}, _from, state) do
    {:reply, :ok, state ++ [message]}
  end

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
end
