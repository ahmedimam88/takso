defmodule TaksoWeb.Router do
  use TaksoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    #plug Takso.Authentication, repo: Takso.Repo
  end

  pipeline :browser_auth do
    plug Takso.AuthPipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TaksoWeb do
    pipe_through [:browser]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/", TaksoWeb do
    pipe_through [:browser, :browser_auth]
    get "/", PageController, :index
  end

  scope "/", TaksoWeb do
    pipe_through [:browser, :browser_auth, :ensure_auth]
    resources "/users", UserController
    get "/bookings/possible_allocations", BookingController, :possible_allocations
    get "/bookings/summary", BookingController, :summary
    post "/bookings/summary", BookingController, :submit_requests
    get "/bookings/requests" , BookingController, :booking_requests
    resources "/bookings", BookingController
    get "/requests/:id/approve" , TaxiController, :approve
    get "/requests/:id/reject" , TaxiController, :reject
    resources "/requests" , TaxiController


  end

  # Other scopes may use custom stacks.
  # scope "/api", TaksoWeb do
  #   pipe_through :api
  # end
end
