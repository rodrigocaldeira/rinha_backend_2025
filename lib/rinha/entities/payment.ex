defmodule Rinha.Entities.Payment do
  alias Ecto.Changeset
  alias Rinha.Repo
  alias Rinha.Schemas.Payment, as: PaymentSchema
  alias Rinha.Schemas.Support.Amount

  import Ecto.Query

  def insert(payment) do
    payment = %{payment | amount: Amount.to_integer(payment.amount)}

    PaymentSchema.changeset(%PaymentSchema{}, payment)
  end

  def set_processor(payment, processor) do
    Changeset.change(payment, %{processor: processor})
  end

  def purge, do: Repo.delete_all(PaymentSchema)

  def summary(params) do
    IO.inspect(params)
    from_param = params["from"]
    to_param = params["to"]

    conditions = true

    conditions =
      if from_param do
        dynamic([p], p.inserted_at >= ^from_param)
      else
        conditions
      end

    conditions =
      if to_param do
        dynamic([p], p.inserted_at <= ^to_param)
      else
        conditions
      end

    from(p in PaymentSchema,
      group_by: p.processor,
      select: %{
        processor: p.processor,
        totalRequests: count(p.id),
        totalAmount: sum(p.amount)
      },
      where: ^conditions
    )
    |> Repo.all()
    |> Map.new(fn payment ->
      values =
        payment
        |> Map.delete(:processor)
        |> Map.update(:totalAmount, 0, &Amount.to_float(&1))

      {String.to_existing_atom(payment.processor), values}
    end)
    |> ensure_summary_integrity()
  end

  @default_summary_aggregates %{totalRequests: 0, totalAmount: 0}

  defp ensure_summary_integrity(summary) do
    summary
    |> Map.put_new(:default, @default_summary_aggregates)
    |> Map.put_new(:fallback, @default_summary_aggregates)
  end
end
