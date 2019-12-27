defmodule TaksoWeb.BookingControllerTest do
  use TaksoWeb.ConnCase

  alias Takso.Guardian
  alias Takso.Accounts.User
  alias Takso.{Repo,Sales.Taxi}

  import Ecto.Query, only: [from: 2]

  setup do
    user = Repo.get!(User, 1)
    conn = build_conn()
           |> bypass_through(Takso.Router, [:browser, :browser_auth, :ensure_auth])
           |> get("/")
           |> Map.update!(:state, fn (_) -> :set end)
           |> Guardian.Plug.sign_in(user)
           |> send_resp(200, "Flush the session")
           |> recycle
    {:ok, conn: conn}
  end

  # Tests fail if you don't provide a valid Bing Key on the
  # file: /takso_web/services/geolocation.ex
  ###

  test "Taxi available", %{conn: conn} do
    Repo.insert!(%Taxi{status: "AVAILABLE"})
    conn = post conn, "/bookings", %{booking: [ pickup_address: "Raja 4D, Tallinn", dropoff_address: "Tallinn Old Town"]}
    assert html_response(conn, 200) =~ ~r/At present, there is taxi available!/
  end

  test "Booking rejection", %{conn: conn} do
    Repo.insert!(%Taxi{status: "BUSY"})
    conn = post conn, "/bookings", %{booking: [status: "OPEN" ,pickup_address: "Juhan Liivi 2, Tartu", dropoff_address: "Lõunakeskus, Tartu"]}
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/At present, there is no taxi available!/
  end


  test "Booking aceptance", %{conn: conn} do
    Repo.insert!(%Taxi{status: "AVAILABLE", location: "Raatuse 22, 51009 Tartu"})
    conn = post conn, "/bookings", %{booking: [pickup_address: "Juhan Liivi 2, Tartu", dropoff_address: "Lõunakeskus, Tartu"]}
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~  ~r/Your taxi will arrive in \d+ minutes/
  end

  test "Booking Acceptance by shortest distance", %{conn: conn} do
    Repo.insert!(%Taxi{status: "AVAILABLE", location: "Ringtee 75, 50501 Tartu"})
    #Repo.insert!(%Booking{status: "OPEN", location: "Ringtee 75, 50501 Tartu"})
    Repo.insert!(%Taxi{status: "AVAILABLE", location: "Raatuse 22, 51009 Tartu"})

    query = from t in Taxi, where: t.status == "AVAILABLE", select: t
    [t1, _] = Repo.all(query)
    assert t1.location == "Ringtee 75, 50501 Tartu"

    conn = post conn, "/bookings", %{booking: [pickup_address: "Juhan Liivi 2, Tartu", dropoff_address: "Lõunakeskus, Tartu"]}
    conn = get conn, redirected_to(conn)

    query = from t in Taxi, where: t.status == "available", select: t
    [t2, _] = Repo.all(query)

    response = html_response(conn, 200)
    #just added this line
    matches = Regex.named_captures(~r/Your taxi will arrive in (?<dur>\d+) minutes/, response)
    assert matches["dur"] == "8"
    # assert matches["dur"] == "8"
    # assert t2.location == "Raatuse 22, 51009 Tartu"
  end

end
