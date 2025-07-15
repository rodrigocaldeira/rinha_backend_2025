defmodule Rinha do
  alias Rinha.Entities.Payment
  alias Rinha.Processor.Client

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
      Node.spawn(@worker_node, Rinha.Queue, :enqueue, [payment])
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
        Logger.info("Payment #{payment.correlation_id} done.")

      :error ->
        Logger.warning("Retrying payment #{payment.correlation_id}.")
        Rinha.Queue.enqueue(payment)
        :ok
    end
  end
end
