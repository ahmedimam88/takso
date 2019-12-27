defmodule Takso.Repo.Migrations.UpdateTaxiTableAddSeatsCountRatePerKmDriverFullName do
  use Ecto.Migration

  def change do
    alter table(:taxis) do
      add :seatscount, :integer
      add :rateperkm, :float
      add :driverfullname, :string
    end
  end
end
