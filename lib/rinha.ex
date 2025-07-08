defmodule Rinha do
  def register_payment(%{"correlationId" => correlation_id, "amount" => amount}) do
    message = %{
      correlation_id: correlation_id,
      amount: amount
    }

    Rinha.Queue.enqueue(message)
  end

  def register_payment(_), do: :error

  def pay(payment) do
    IO.inspect(payment)
  end

  def summary(params) do
    IO.inspect(params)

    %{
      default: %{
        totalRequests: 0,
        totalAmount: 0.0
      },
      fallback: %{
        totalRequests: 0,
        totalAmount: 0.0
      }
    }
  end
end
