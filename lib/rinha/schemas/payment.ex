defmodule Rinha.Schemas.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field(:correlation_id)
    field(:amount, :integer)
    field(:processor)
    field(:requested_at, :utc_datetime_usec)
  end

  @fields [:correlation_id, :amount, :processor, :requested_at]

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:correlation_id)
  end
end
