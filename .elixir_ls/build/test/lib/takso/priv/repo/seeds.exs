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

[%{username: "Hany", location: "as222", status: "available",SeatsCount: 4,RatePerKm: 1.5,DriverFullName: "Hany Ali Mohamed"},
 %{username: "Barn", location: "1wwww", status: "available",SeatsCount: 7,RatePerKm: 2,DriverFullName: "Barn John Sam"},
 %{username: "Sam", location: "we23ss", status: "available",SeatsCount: 4,RatePerKm: 1.4,DriverFullName: "Sam Kamel"}]
|> Enum.map(fn taxis_data -> Taxi.changeset(%Taxi{}, taxis_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
