defmodule Rinha do
  alias Rinha.Entities.Payment
  alias Rinha.Processor.Client
  alias Rinha.Schemas.Support.Error

  require Logger

  def register_payment(%{"correlationId" => correlation_id, "amount" => amount}) do
    payment = %{
      correlation_id: correlation_id,
      amount: amount,
      requested_at: DateTime.utc_now(:millisecond)
    }

    Rinha.Queue.enqueue(payment)

    Logger.info("Registered payment #{inspect(payment)}")
  end

  def register_payment(payment) do
    Logger.warning("Invalid payment params on registration: #{inspect(payment)}")

    :error
  end

  def pay do
    payment = Rinha.Queue.dequeue()

    Client.pay(payment)
    |> case do
      {:ok, processor} ->
        payment = Map.put(payment, :processor, processor)

        Payment.pay(payment)
        |> case do
          {:ok, _} ->
            Logger.info("Payment #{payment.correlation_id} done.")

          {:error, changeset} ->
            error = Error.extract_error(:payment, changeset)
            Logger.warning("Error paying #{payment.correlation_id}: #{error}")
        end

      {:error, error} ->
        Logger.warning("Error paying #{payment.correlation_id}: #{error}")
    end
  end

  defdelegate purge, to: Payment
  defdelegate summary(params), to: Payment

  def purge_all do
    __MODULE__.purge()
    Client.purge()
  end
end
