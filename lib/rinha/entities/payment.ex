defmodule Rinha.Entities.Payment do
  alias Ecto.Changeset
  alias Rinha.Repo
  alias Rinha.Schemas.Payment, as: PaymentSchema
  alias Rinha.Schemas.Support.Amount

  import Ecto.Query

  def insert(payment) do
    payment = %{payment | amount: Amount.to_integer(payment.amount)}

    PaymentSchema.changeset(%PaymentSchema{}, payment)
    |> Repo.insert()
  end

  def set_processor(payment, processor) do
    Changeset.change(payment, %{processor: processor})
  end

  def purge, do: Repo.delete_all(PaymentSchema)

  def summary(params) do
    from_param = params["from"]
    to_param = params["to"]

    date_conditions =
      cond do
        from_param && to_param ->
          dynamic([p], p.inserted_at >= ^from_param and p.inserted_at <= ^to_param)

        from_param ->
          dynamic([p], p.inserted_at >= ^from_param)

        to_param ->
          dynamic([p], p.inserted_at <= ^to_param)

        true ->
          true
      end

    conditions = dynamic([p], not is_nil(p.processor) and ^date_conditions)

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

  def list_failed_payments do
    from(p in PaymentSchema,
      select: p,
      where: is_nil(p.processor)
    )
    |> Repo.all()
  end

  @summary_aggregates %{totalRequests: 0, totalAmount: 0}

  defp ensure_summary_integrity(summary) do
    summary
    |> Map.put_new(:default, @summary_aggregates)
    |> Map.put_new(:fallback, @summary_aggregates)
  end
end
