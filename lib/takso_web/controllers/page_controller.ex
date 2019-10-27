defmodule TaksoWeb.PageController do
  use TaksoWeb, :controller
  alias Takso.{Authentication, Repo}
  alias Takso.Accounts.User

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
