defmodule Rinha.DB do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def purge do
    Agent.update(__MODULE__, fn _ -> [] end)
  end

  def pay(payment) do
    Agent.update(__MODULE__, fn payments -> payments ++ [payment] end)
  end

  def summary(params) do
    filter = filter_function(params)

    Agent.get(__MODULE__, fn payments ->
      payments
      |> Enum.filter(filter)
      |> Enum.reduce(zero_summary(), fn payment, acc ->
        Map.update(acc, payment["processor"], nil, fn processor ->
          total_amount = processor["totalAmount"] + payment["amount"]
          total_requests = processor["totalRequests"] + 1

          %{
            "totalAmount" => total_amount,
            "totalRequests" => total_requests
          }
        end)
      end)
    end)
  end

  def filter_function(%{"from" => from, "to" => to}) do
    fn payment ->
      payment["requestedAt"] >= from and payment["requestedAt"] <= to
    end
  end

  def filter_function(_), do: fn _ -> true end

  defp zero_summary do
    %{
      "default" => %{
        "totalAmount" => 0,
        "totalRequests" => 0
      },
      "fallback" => %{
        "totalAmount" => 0,
        "totalRequests" => 0
      }
    }
  end
end
