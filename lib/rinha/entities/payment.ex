defmodule Rinha.Entities.Payment do
  alias Ecto.Changeset
  alias Rinha.Repo
  alias Rinha.Schemas.Payment, as: PaymentSchema
  alias Rinha.Schemas.Support.Amount

  def insert(payment) do
    payment = %{payment | amount: Amount.to_integer(payment.amount)}

    PaymentSchema.changeset(%PaymentSchema{}, payment)
  end

  def set_processor(payment, processor) do
    Changeset.change(payment, %{processor: processor})
  end

  def purge, do: Repo.delete_all(PaymentSchema)
end
