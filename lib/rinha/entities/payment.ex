defmodule Rinha.Entities.Payment do
  alias Rinha.Schemas

  def insert(payment) do
    payment = amount_to_integer(payment)

    Schemas.Payment.changeset(%Schemas.Payment{}, payment)
  end

  def set_processor(payment, processor) do
    Ecto.Changeset.change(payment, %{processor: processor})
  end

  defp amount_to_integer(%{amount: amount} = payment) do
    %{payment | amount: to_integer(amount)}
  end

  defp to_integer(number) do
    number
    |> Kernel.*(100)
    |> Float.round(2)
    |> trunc
  end
end
