defmodule Rinha do
  alias Rinha.Entities.Payment
  alias Rinha.Processor.Client
  alias Rinha.Schemas.Support.Error

  require Logger

  @worker_node :worker@worker

  def register_payment(%{"correlationId" => correlation_id, "amount" => amount}) do
    Task.async(fn ->
      payment = %{
        correlation_id: correlation_id,
        amount: amount,
        requested_at: DateTime.utc_now(:millisecond)
      }

      Rinha.enqueue(payment)

      Logger.info("Registered payment #{inspect(payment)}")
    end)

    :ok
  end

  def register_payment(payment) do
    Logger.warning("Invalid payment: #{inspect(payment)}")

    :error
  end

  def enqueue(payment) do
    role = Application.get_env(:rinha, :role)

    if role == "api" do
      Node.spawn(@worker_node, fn -> Rinha.Queue.enqueue(payment) end)
    else
      Rinha.Queue.enqueue(payment)
    end
  end

  def summary(params) do
    role = Application.get_env(:rinha, :role)

    if role == "api" do
      supervisor = {Rinha.TaskSupervisor, @worker_node}

      Task.Supervisor.async(supervisor, Payment, :summary, [params])
      |> Task.await()
    else
      Payment.summary(params)
    end
  end

  def purge do
    role = Application.get_env(:rinha, :role)

    if role == "api" do
      Node.spawn(@worker_node, fn -> Payment.purge() end)
    else
      Payment.purge()
    end
  end

  def purge_all do
    __MODULE__.purge()
    Client.purge()
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
        Rinha.Queue.enqueue(payment)
    end
  end
end
