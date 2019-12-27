defmodule Takso.Sales.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :pickup_address, :string
    field :dropoff_address, :string
    field :status, :string, default: "open"
    belongs_to :user, Takso.Accounts.User

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:pickup_address, :dropoff_address, :status])
    |> validate_required([:pickup_address, :dropoff_address])
  end
end
