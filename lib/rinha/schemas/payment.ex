defmodule Rinha.Schemas.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field(:correlation_id)
    field(:amount, :integer)
    field(:processor)

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields [:correlation_id, :amount]
  @fields @required_fields ++ [:processor]

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:correlation_id)
  end
end
