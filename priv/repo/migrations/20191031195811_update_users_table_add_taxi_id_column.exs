defmodule Takso.Repo.Migrations.UpdateUsersTableAddTaxiIdColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :taxi_id, references(:taxis)
    end
  end
end
