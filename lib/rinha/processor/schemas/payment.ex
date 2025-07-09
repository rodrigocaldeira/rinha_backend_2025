defmodule Rinha.Processor.Schemas.Payment do
  alias Rinha.Schemas.Payment, as: InternalPayment
  alias Rinha.Schemas.Support.Amount

  @derive Jason.Encoder
  defstruct [:correlationId, :amount, :requestedAt]

  def new(%InternalPayment{} = payment) do
    %__MODULE__{
      correlationId: payment.correlation_id,
      amount: Amount.to_float(payment.amount),
      requestedAt: payment.inserted_at
    }
  end
end
