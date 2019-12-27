defmodule Takso.Repo.Migrations.CreateTableTaxiRequests do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add :status, :string
      add :booking_id, references(:bookings)
      add :taxi_id, references(:taxis)

      timestamps()

  end
  create unique_index(:requests, [:booking_id, :taxi_id])
  end
end
