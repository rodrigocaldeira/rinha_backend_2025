defmodule Rinha do
  alias Rinha.Entities.Payment
  alias Rinha.Processor.Client

  require Logger

  @worker_node :worker@worker

  def pay do
    payment = Rinha.Queue.dequeue()

    Client.pay(payment)
    |> case do
      {:ok, payment_on_processor} ->
        Payment.pay(payment_on_processor)
        Logger.info("#{payment["correlationId"]} OK")

      :error ->
        Logger.warning("#{payment["correlationId"]} failed")
        Rinha.Queue.enqueue(payment)
        :ok
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
end
