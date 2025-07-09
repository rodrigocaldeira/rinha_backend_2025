defmodule Rinha.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :correlation_id, :string, null: false
      add :amount, :integer, null: false
      add :processor, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:payments, [:correlation_id])
  end
end
