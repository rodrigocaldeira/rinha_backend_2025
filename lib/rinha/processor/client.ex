defmodule Rinha.Processor.Client do
  alias Rinha.Processor.Schemas.Payment
  alias Rinha.Schemas.Payment, as: InternalPayment

  def pay(%InternalPayment{} = internal_payment) do
    payment = Payment.new(internal_payment)

    Req.post("http://localhost:8001/payments", json: payment)
    |> case do
      {:ok, %Req.Response{status: 200}} = response ->
        response

      error ->
        IO.inspect(error)
        {:error, :processor_error}
    end
  end

  def purge do
    Req.post("http://localhost:8001/admin/purge-payments",
      headers: [{"X-Rinha-Token", "123"}])
  end
end
