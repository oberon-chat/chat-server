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
  secret_key_base: System.get_env("CHAT_OAUTH2_SECRET_KEY_BASE"),
  render_errors: [view: ChatOAuth2Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: ChatOAuth2.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Guardian
config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "ChatOAuth2",
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: System.get_env("CHAT_OAUTH2_GUARDIAN_SECRET_KEY"),
  serializer: ChatOAuth2.Guardian.Serializer

# OAuth2 Facebook
config :oauth2_facebook, OAuth2.Provider.Facebook,
  client_id: System.get_env("CHAT_OAUTH2_FACEBOOK_APP_ID"),
  client_secret: System.get_env("CHAT_OAUTH2_FACEBOOK_APP_SECRET")

# OAuth2 GitHub
config :oauth2_github, OAuth2.Provider.GitHub,
  client_id: System.get_env("CHAT_OAUTH2_GITHUB_APP_ID"),
  client_secret: System.get_env("CHAT_OAUTH2_GITHUB_APP_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
