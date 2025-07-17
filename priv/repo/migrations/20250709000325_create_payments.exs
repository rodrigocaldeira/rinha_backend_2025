defmodule Rinha.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments, primary_key: false) do
      add :correlationId, :uuid, primary_key: true
      add :amount, :float, null: false
      add :processor, :string
      add :requestedAt, :utc_datetime_usec
    end

    create index(:payments, [:requestedAt])
  end
end
