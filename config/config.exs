# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :japanese_verb_conjugation,
  ecto_repos: [JapaneseVerbConjugation.Repo]

# Configures the endpoint
config :japanese_verb_conjugation, JapaneseVerbConjugationWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AB9ZzSg/JG3I4c0Ec6GFMaMCoQvz+DOUNz0wmXGOXQqSQeZiMDrYk4k4oCamg3yO",
  render_errors: [
    view: JapaneseVerbConjugationWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: JapaneseVerbConjugation.PubSub,
  live_view: [signing_salt: "hZmCONBJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
