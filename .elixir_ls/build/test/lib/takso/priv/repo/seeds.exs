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

alias Takso.{Repo, Accounts.User}
alias Takso.{Repo, Sales.Taxi}


[%{name: "Fred Flintstone", username: "fred", password: "parool"},
 %{name: "Barney Rubble", username: "barney", password: "parool"}]
|> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

[%{username: "Hany", location: "as222", status: "AVAILABLE",seatscount: 4,rateperkm: 1.5,driverfullname: "Hany Ali Mohamed"},
 %{username: "Barn", location: "1wwww", status: "AVAILABLE",seatscount: 7,rateperkm: 2,driverfullname: "Barn John Sam"},
 %{username: "Sam", location: "we23ss", status: "AVAILABLE",seatscount: 4,rateperkm: 1.4,driverfullname: "Sam Kamel"}]
|> Enum.map(fn taxis_data -> Taxi.changeset(%Taxi{}, taxis_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
