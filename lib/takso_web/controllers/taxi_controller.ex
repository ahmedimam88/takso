defmodule TaksoWeb.TaxiController do
    use TaksoWeb, :controller
    import Ecto.Query, only: [from: 2]
    alias Takso.{Repo, Authentication}
    alias Ecto.{Changeset, Multi}
    alias Takso.Sales.{Taxi, Booking, Allocation, Request}
    alias Takso.Accounts.User

    def index(conn, _params) do
        query = from u in User, where: u.id == ^Takso.Authentication.load_current_user(conn).id, select: u.taxi_id
        driverl = Repo.all(query) 
        driver = driverl |> hd
        case driver != nil do
        true ->    reqquery = from r in Request, 
                        join: b in Booking, on: r.booking_id == b.id,
                        where: r.taxi_id == ^driver and r.status == "NEW" and b.status == "OPEN", 
                        select: b

                    requests = Repo.all(reqquery)
            render conn, "index.html", requests: requests
            
        _ -> reqquery = from r in Request, 
                join: b in Booking, on: r.booking_id == b.id,
                where: r.taxi_id == -1 and r.status == "NEW" and b.status == "OPEN", 
                select: {r.id, r.status, b.pickup_address, b.dropoff_address}
                requests = Repo.all (reqquery)
            render conn, "index.html", requests: requests, var: Kernel.inspect(driver)
        
        end

      end

      defp approve_requests(conn,[h|t],booking_id) do
        query = from u in User, where: u.id == ^Takso.Authentication.load_current_user(conn).id, select: u.taxi_id
        taxi_id = (Repo.all(query)) |> hd 
        case taxi_id == h.taxi_id do
            true -> request = Repo.get!(Request, h.id)
                    Request.changeset(request) |> Changeset.put_change(:status, "ALLOCATED") |> Repo.update

            false -> request = Repo.get!(Request, h.id)
                    Request.changeset(request) |> Changeset.put_change(:status, "REJECTED") |> Repo.update
        end
        approve_requests(conn,t,booking_id)
      end

      defp approve_requests(conn,[],booking_id) do
          
      end

      defp reject_other_requests(conn,[h|t],booking_id) do
        
         request = Repo.get!(Request, h.id)
         Request.changeset(request) |> Changeset.put_change(:status, "REJECTED") |> Repo.update

        reject_other_requests(conn,t,booking_id)
      end

      defp reject_other_requests(conn,[],booking_id) do
          
      end

      def approve(conn,%{"id" => id}) do
        query = from u in User, where: u.id == ^Takso.Authentication.load_current_user(conn).id, select: u.taxi_id
        taxi_id = (Repo.all(query)) |> hd 
        taxi = Repo.get!(Taxi, taxi_id)
        case taxi.status == "AVAILABLE" do
            
          true ->   
            booking = Repo.get!(Booking, id)
            reqquery = from r in Request , where:  r.status == "NEW" and r.booking_id == ^id,  select: r
            requests = Repo.all(reqquery)
            otherrequestsquery = from r in Request , where:  r.taxi_id == ^taxi.id and r.booking_id != ^id,  select: r
            otherrequests = Repo.all(otherrequestsquery)
            approve_requests(conn,requests,id)
            reject_other_requests(conn,otherrequests, id)

            # Create allocation
            
            query = from t in Taxi, where: t.id == ^taxi_id, select: t
            taxi = (Repo.all(query)) |> hd
            # 
            Multi.new
            |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "ACCEPTED"}) |> Changeset.put_change(:booking_id, String.to_integer(id)) |> Changeset.put_change(:taxi_id, taxi_id))
            |> Multi.update(:taxi, Taxi.changeset(taxi, %{}) |> Changeset.put_change(:status, "BUSY"))
            |> Multi.update(:booking, Booking.changeset(booking, %{}) |> Changeset.put_change(:status, "ALLOCATED"))
            |> Repo.transaction

            conn
            |> put_flash(:info, "Request Approved successfully.")
            |> redirect(to: taxi_path(conn, :index))

        _ -> conn
            |> put_flash(:info, "You are Currently allocated to a booking, You can't accept another one."<>Kernel.inspect(taxi.status))
            |> redirect(to: taxi_path(conn, :index))
        end 
      end

      def reject(conn,%{"id" => id}) do
        query = from u in User, where: u.id == ^Takso.Authentication.load_current_user(conn).id, select: u.taxi_id
        taxi_id = (Repo.all(query)) |> hd 
        reqquery = from r in Request , where:  r.taxi_id == ^taxi_id and r.booking_id == ^id,  select: r
        request = (Repo.all(reqquery) ) |> hd
        Request.changeset(request, %{}) |> Changeset.put_change(:status, "REJECTED") |> Repo.update

        check_booking_status(conn,id)
        conn
        |> put_flash(:info, "Request Rejected successfully.")
        |> redirect(to: taxi_path(conn, :index))

        

      end

      defp check_booking_status(conn, booking_id) do
        reqquery = from r in Request , where:  r.booking_id == ^booking_id and r.status == "NEW",  select: r
        remaining_requests = Repo.all(reqquery)
        case length(remaining_requests) == 0 do
            true -> book_query = from b in Booking, where: b.id == ^booking_id, select: b
                    booking = (Repo.all(book_query) ) |> hd
                    Request.changeset(booking, %{}) |> Changeset.put_change(:status, "REJECTED") |> Repo.update
                    
            false -> length(remaining_requests)
        end
        
      end

    
end