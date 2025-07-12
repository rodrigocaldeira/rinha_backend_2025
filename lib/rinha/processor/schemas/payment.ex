defmodule Rinha.Processor.Schemas.Payment do
  @derive Jason.Encoder
  defstruct [:correlationId, :amount, :requestedAt]

  def new(payment) do
    %__MODULE__{
      correlationId: payment.correlation_id,
      amount: payment.amount,
      requestedAt: payment.requested_at
    }
  end
end
