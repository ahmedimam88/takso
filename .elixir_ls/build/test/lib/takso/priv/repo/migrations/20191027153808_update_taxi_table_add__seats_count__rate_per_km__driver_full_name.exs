defmodule Takso.Repo.Migrations.UpdateTaxiTableAdd_SeatsCount_RatePerKm_DriverFullName do
  use Ecto.Migration

  def change do
    alter table(:taxis) do
      add :SeatsCount, :integer
      add :RatePerKm, :float
      add :DriverFullName, :string
    end
  end
end
