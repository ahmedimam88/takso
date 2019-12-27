# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Takso.Repo.insert!(%Takso.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Takso.{Repo, Accounts.User, Sales.Taxi}

[%{username: "Hany", location: "Liiva 2", status: "AVAILABLE",seatscount: 4,rateperkm: 1.5,driverfullname: "Hany Ali Mohamed"},
 %{username: "Barn", location: "Riia 5", status: "AVAILABLE",seatscount: 7,rateperkm: 2,driverfullname: "Barn John Sam"},
 %{username: "Sam", location: "Raatuse 25", status: "AVAILABLE",seatscount: 4,rateperkm: 1.4,driverfullname: "Sam Kamel"}]
|> Enum.map(fn taxis_data -> Taxi.changeset(%Taxi{}, taxis_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

[%{name: "Fred Flintstone", username: "fred", password: "parool", taxi_id: nil},
 %{name: "Barney Rubble", username: "barney", password: "parool", taxi_id: nil},
 %{name: "Hany Ali Mohamed", username: "hany", password: "parool", taxi_id: 1},
 %{name: "Barn John Sam", username: "barn", password: "parool", taxi_id: 2},
 %{name: "Sam Kamel", username: "sam", password: "parool", taxi_id: 3}]
|> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)


