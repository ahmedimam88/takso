defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers

  alias Takso.{Repo,Sales.Taxi}

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end

  scenario_starting_state fn state ->
    #Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Takso.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Takso.Repo, {:shared, self()})
    %{}
  end

  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Takso.Repo)
    #Hound.end_session
    nil
  end
  given_ ~r/^the following taxis are on duty$/, fn state ->
    {:ok, state}
  end
  and_ ~r/^I want to go from "(?<pickup_address>[^"]+)" to "(?<dropoff_address>[^"]+)"$/,
  fn state, %{pickup_address: pickup_address,dropoff_address: dropoff_address} ->
    {:ok, state}
  end
  and_ ~r/^I open STRS' web page$/, fn state ->
    {:ok, state}
  end
  and_ ~r/^I enter the booking information$/, fn state ->
    {:ok, state}
  end
  when_ ~r/^I summit the booking request$/, fn state ->
    {:ok, state}
  end
  then_ ~r/^I should receive a confirmation message$/, fn state ->
    {:ok, state}
  end
  and_ ~r/^all drivers are OFF-DUTY$/, fn state ->
    {:ok, state}
  end
  then_ ~r/^I should receive a rejection message$/, fn state ->
    {:ok, state}
  end
  and_ ~r/^customer want to go from "(?<pickup_address>[^"]+)" to "(?<dropoff_address>[^"]+)"$/,
  fn state, %{pickup_address: pickup_address,dropoff_address: dropoff_address} ->
    {:ok, state}
  end
  and_ ~r/^I accept taxi ride$/, fn state ->
    {:ok, state}
  end
end
