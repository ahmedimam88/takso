defmodule TaksoWeb.BookingController do
  use TaksoWeb, :controller
  import Ecto.Query, only: [from: 2]
  alias Takso.{Repo, Authentication}
  alias Ecto.{Changeset, Multi}
  alias Takso.Sales.{Taxi, Booking, Allocation, Request}
  alias Takso.Geolocation


  def index(conn, _params) do
    user = Authentication.load_current_user(conn)
    bookings = Repo.all(from b in Booking, where: b.user_id == ^user.id)
    render conn, "index.html", bookings: bookings
  end

  def new(conn, _params) do
    changeset = Booking.changeset(%Booking{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"booking" => booking_params}) do
    openbookingquery = from b in Booking, where: (b.status == "OPEN" or b.status == "ALLOCATED") and b.user_id == ^Takso.Authentication.load_current_user(conn).id, select: b
    openbookings = Repo.all(openbookingquery)

    case length(openbookings) == 0 do

    true ->
      user = Takso.Authentication.load_current_user(conn)

      booking_struct = Ecto.build_assoc(user, :bookings, Enum.map(booking_params, fn({key, value}) -> {String.to_atom(key), value} end))
      changeset = Booking.changeset(booking_struct, %{}) |> Changeset.put_change(:status, "OPEN")

      booking = Repo.insert!(changeset)

      query = from t in Taxi, where: t.status == "AVAILABLE", select: t
      available_taxis = Repo.all(query)
      [dist, dur] = Geolocation.distance(booking.pickup_address,booking.dropoff_address)

      case length(available_taxis) > 0 do
        true -> conn
                |> put_flash(:info, "Please choose prefered taxi, The total distance is " <> Kernel.inspect(dist) <> " KM and the duration of the trip is " <> Kernel.inspect(dur) )
                |> redirect(to: booking_path(conn, :possible_allocations))

        _    -> Booking.changeset(booking) |> Changeset.put_change(:status, "REJECTED")
                |> Repo.update

                conn
                |> put_flash(:info, "At present, there is no taxi available!")
                #|> redirect(to: booking_path(conn, :index))
      end
  _ -> conn
        |> put_flash(:info, "You already have an open booking!")
        |> redirect(to: booking_path(conn, :index))
    end
  end

  def possible_allocations(conn, _params) do

    query = from t in Taxi, where: t.status == "AVAILABLE", select: t
    possible_taxis = Repo.all(query)
    query2 = from b in Booking, where: b.status == "OPEN" and b.user_id == ^Takso.Authentication.load_current_user(conn).id, select: b
    booking = Repo.all(query2) |> hd
    [dist, dur] = Geolocation.distance(booking.pickup_address,booking.dropoff_address)

    render conn, "options.html", possible_taxis: possible_taxis, dist: dist, dur: dur
  end

  def submit_requests(conn, submit_params) do
    query = from b in Booking, where: b.status == "OPEN" and b.user_id == ^Takso.Authentication.load_current_user(conn).id, select: b
    booking = Repo.all(query) |> hd
    tagsl = checked_ids(conn, "tags")
    #tags = Kernel.inspect(tags)   #---> this is to see the string output
    case length(tagsl) > 0 do
      true  -> add_requests(conn,tagsl,booking)
      false -> Booking.changeset(booking) |> Changeset.put_change(:status, "CANCELLED")
            |> Repo.update

            conn
            |> put_flash(:info, "You didn't choose any taxi driver, your booking will be cancelled")
            |> redirect(to: booking_path(conn, :index))
    end
  end



  defp add_requests(conn,[head | tail],booking) do
    Multi.new
      |> Multi.insert(:request, Request.changeset(%Request{}, %{status: "NEW"}) |> Changeset.put_change(:booking_id, booking.id) |> Changeset.put_change(:taxi_id, head))
      |> Repo.transaction

      add_requests(conn,tail,booking)
  end
  defp add_requests(conn,[],_params) do
    conn
    |> put_flash(:info, "Please Hold until one taxi driver approves your request")
    |> redirect(to: booking_path(conn, :index))
  end

  @spec summary(Plug.Conn.t(), any) :: Plug.Conn.t()



  defp checked_ids(conn, checked_list) do
    conn.params[checked_list]
    |> filter_true_checkbox
  end

  defp filter_true_checkbox(checkbox_list) do
    checkbox_list
    |> Enum.map(&(do_get_id_if_true(&1)))
    |> Enum.filter(&(&1 != nil))
  end

  defp do_get_id_if_true(tuple) do
    case tuple do
      {id, "true"} -> String.to_integer id
      _ -> nil
    end
  end

def delete(conn, %{"id" => id}) do
    booking = Repo.get!(Booking, id)
    case booking.status == "OPEN" do
      true ->
              Booking.changeset(booking) |> Changeset.put_change(:status, "CANCELLED") |> Repo.update
              taxiquery = from r in Request, where: r.booking_id == ^id #, select: r
              Repo.update_all(taxiquery, set: [status: "CANCELLED"] )
              conn
              |> put_flash(:info, "Booking Cancelled successfully.")
              |> redirect(to: booking_path(conn, :index))
      false ->

              conn
              |> put_flash(:info, "You can't cancel this booking.")
              |> redirect(to: booking_path(conn, :index))
      end
end

def summary(conn, _params) do
  query = from t in Taxi,
          join: a in Allocation, on: t.id == a.taxi_id,
          group_by: t.username,
          where: a.status == "ACCEPTED",
          select: {t.username, count(a.id)}
  tuples = Repo.all(query)
  render conn, "summary.html", tuples
end

end
