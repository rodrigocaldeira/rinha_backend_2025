defmodule Rinha.Schemas.Support.Error do
  require Logger

  def extract_error(:payment, changeset) do
    errors_on(changeset)
    |> case do
      %{correlation_id: ["has already been taken"]} ->
        :duplicated_payment

      _ ->
        :unknown_payment_error
    end
  end

  def extract_error(:processor, error), do: error

  def extract_error(operation, changeset) do
    Logger.error("UNMAPPED ERROR. #{operation}: #{inspect(changeset)}")
    :totally_unmapped_error
  end

  # :)
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
