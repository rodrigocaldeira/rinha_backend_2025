defmodule Rinha.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :correlation_id, :string, null: false
      add :amount, :float, null: false
      add :processor, :string
      add :requested_at, :utc_datetime_usec
    end

    create unique_index(:payments, [:correlation_id])
    create index(:payments, [:processor])
    create index(:payments, [:requested_at])
  end
end
