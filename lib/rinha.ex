defmodule Rinha do
  alias Ecto.Multi
  alias Rinha.Repo
  alias Rinha.Schemas.Support.Error
  alias Rinha.Entities.Payment

  require Logger

  def register_payment(%{"correlationId" => correlation_id, "amount" => amount}) do
    payment = %{
      correlation_id: correlation_id,
      amount: amount
    }

    :ok = Rinha.Queue.enqueue(payment)

    Logger.info("Registered payment #{inspect(payment)}")
  end

  def register_payment(params) do
    Logger.warning("Invalid payment params on registration: #{inspect(params)}")

    :error
  end

  def pay(payment) do
    Multi.new()
    |> Multi.insert(:payment, Payment.insert(payment))
    |> Multi.update(:set_processor, fn %{payment: payment} ->
      Payment.set_processor(payment, "default")
    end)
    |> Repo.transact()
    |> IO.inspect()
    |> case do
      {:ok, _} ->
        Logger.info("Successful payment #{inspect(payment)}")

      {:error, operation, changeset, _} ->
        error = Error.extract_error(operation, changeset)
        Logger.warning("Error during payment #{inspect(payment)}: #{error}")
    end
  end

  def summary(_params) do
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
