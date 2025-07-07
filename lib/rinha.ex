defmodule Rinha do
  def pay(%{"correlationId" => _, "amount" => _}), do: :ok
  def pay(_), do: :error

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
