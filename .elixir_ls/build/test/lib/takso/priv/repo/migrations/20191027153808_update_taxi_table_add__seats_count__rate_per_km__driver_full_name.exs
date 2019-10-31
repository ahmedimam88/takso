defmodule Takso.Repo.Migrations.UpdateTaxiTableAdd_SeatsCount_RatePerKm_DriverFullName do
  use Ecto.Migration

  def change do
    alter table(:taxis) do
      add :seatscount, :integer
      add :rateperkm, :float
      add :driverfullname, :string
    end
  end
end
