defmodule Rinha.Schemas.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:correlationId, :binary_id, autogenerate: false}
  schema "payments" do
    field(:amount, :float)
    field(:processor)
    field(:requestedAt, :utc_datetime_usec)
  end

  @fields [:correlationId, :amount, :processor, :requestedAt]

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, @fields)
  end
end
