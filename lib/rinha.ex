defmodule Rinha do
  alias Rinha.Processor.Client
  alias Rinha.Processor.Services

  def pay do
    payment = Rinha.Queue.dequeue()

    if not is_nil(payment) do
      with {:ok, {processor, url}} <- Services.get_service(),
           {:ok, payment_on_processor} <- Client.pay(payment, processor, url) do
        Rinha.DB.pay(payment_on_processor)
      else
        {:error, :no_service_available} ->
          Rinha.Queue.enqueue(payment)
      end
    end
  end

  defdelegate summary(from, to), to: Rinha.DB
  defdelegate purge, to: Rinha.DB
end
