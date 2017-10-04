# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :chat_oauth2,
  namespace: ChatOAuth2,
  ecto_repos: [ChatOAuth2.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :chat_oauth2, ChatOAuth2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gFb++Kp/aZ3K/MpvPCHj8Vj4iQDKb2HgWcc3bucH+x2oPnaOXKdCxCa63xLgZM9j",
  render_errors: [view: ChatOAuth2Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: ChatOAuth2.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
