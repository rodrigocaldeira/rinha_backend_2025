defmodule Rinha do
  alias Ecto.Multi
  alias Rinha.Entities.Payment
  alias Rinha.Processor.Client
  alias Rinha.Repo
  alias Rinha.Schemas.Support.Error

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

  def pay do
    payment_params = Rinha.Queue.dequeue()

    Payment.insert(payment_params)
    |> case do
      {:ok, payment} ->
        Logger.info("Payment #{payment_params.correlation_id} registered. Completing...")
        complete_payment(payment)

      {:error, changeset} ->
        error = Error.extract_error(:payment, changeset)
        Logger.warning("Error registering payment #{payment_params}: #{error}")
    end
  end

  defdelegate purge, to: Payment
  defdelegate summary(params), to: Payment

  def purge_all do
    __MODULE__.purge()
    Client.purge()
  end

  defp complete_payment(payment) do
    Multi.new()
    |> Multi.run(:processor, fn _, _ ->
      Client.pay(payment)
    end)
    |> Multi.update(:set_processor, fn %{processor: processor} ->
      Payment.set_processor(payment, processor)
    end)
    |> Repo.transact()
    |> case do
      {:ok, _} ->
        Logger.info("Payment #{payment.correlation_id} completed.")

      {:error, operation, changeset, _} ->
        error = Error.extract_error(operation, changeset)
        Logger.warning("Error during payment #{payment.correlation_id}: #{error}")
    end
  end

  def retry_failed_payments do
    Payment.list_failed_payments()
    |> Enum.each(&complete_payment/1)

    :ok
  end
end
