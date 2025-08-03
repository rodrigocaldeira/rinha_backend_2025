defmodule Rinha.Queue do
  def enqueue(payment) do
    :ets.insert(:rinha_queue, {payment["correlationId"], payment})
  end

  def dequeue do
    case :ets.first(:rinha_queue) do
      :"$end_of_table" ->
        nil

      index ->
        [{_, payment}] = :ets.take(:rinha_queue, index)
        payment
    end
  end
end
