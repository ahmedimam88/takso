defmodule Takso.Sales.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    field :status, :string
    belongs_to :booking, Takso.Sales.Booking
    belongs_to :taxi, Takso.Sales.Taxi

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:status])
    |> validate_required([:status])
  end
end
