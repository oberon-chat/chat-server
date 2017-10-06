use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chat_oauth2, ChatOAuth2Web.Endpoint,
  http: [port: 4011],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :chat_oauth2, ChatOAuth2.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("CHAT_OAUTH2_POSTGRES_HOST"),
  username: System.get_env("CHAT_OAUTH2_POSTGRES_USER"),
  password: System.get_env("CHAT_OAUTH2_POSTGRES_PASS"),
  database: System.get_env("CHAT_OAUTH2_POSTGRES_DB") <> "_test",
  pool: Ecto.Adapters.SQL.Sandbox
