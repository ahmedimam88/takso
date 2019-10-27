# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :takso,
  ecto_repos: [Takso.Repo]

# Configures the endpoint
config :takso, TaksoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+aKehWnd5vD1JOE8Kur8Ypgdq2c5vG8P8FQleIkz73P0Vi0+Rnbe0haC1O7IvOII",
  render_errors: [view: TaksoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Takso.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :takso, Takso.Guardian,
  issuer: "takso",
  secret_key: "Odbcnwp1yaktljHFXjv0L1XZjNXS4YVrbmLl3/v59dUEVJciltP/wEKx3FiycxuH"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

