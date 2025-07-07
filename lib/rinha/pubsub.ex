defmodule Rinha.PubSub do
  use GenServer

  @impl true
  def init(_) do
    {:ok, system_defaults()}
  end

  def start_link(defaults) do
    GenServer.start_link(__MODULE__, defaults, name: PubSub)
  end

  def current_state, do: GenServer.call(PubSub, :current_state)

  def reset, do: GenServer.call(PubSub, :reset)

  def subscribe(function), do: GenServer.call(PubSub, {:subscribe, function})

  def publish(message) do
    :ok = GenServer.call(PubSub, {:enqueue, message})
    GenServer.cast(PubSub, :publish)
  end

  @impl true
  def handle_call(:current_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:reset, _from, _) do
    {:reply, :ok, system_defaults()}
  end

  def handle_call({:subscribe, function}, _from, state) do
    subscribers = 
      Enum.find(state.subscribers, fn f -> f == function end)
      |> case do
        nil -> state.subscribers ++ [function]
        _ -> state.subscribers
      end
    {:reply, :ok, %{state | subscribers: subscribers}}
  end

  def handle_call({:enqueue, message}, _from, state) do
    {:reply, :ok, %{state | messages: state.messages ++ [message]}}
  end

  @impl true
  # def handle_cast(:public, %{messages: messages} = state)
  #   when length(messages) < 20 do
  #   {:noreply, state}  
  # end

  def handle_cast(:publish, state) do
    publish_messages(state)
    {:noreply, %{state | messages: []}}
  end

  defp system_defaults do
    %{
      subscribers: [],
      messages: []
    }
  end

  defp publish_messages(%{messages: []}), do: :ok
  defp publish_messages(%{messages: [message | rest]} = state) do
    Enum.each(state.subscribers, fn sub ->
      sub.(message)
    end)

    publish_messages(%{state | messages: rest})
  end
end
