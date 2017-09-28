use Mix.Config

config :chat_server, ChatServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("CHAT_SERVER_POSTGRES_HOST"),
  username: System.get_env("CHAT_SERVER_POSTGRES_USER"),
  password: System.get_env("CHAT_SERVER_POSTGRES_PASS"),
  database: System.get_env("CHAT_SERVER_POSTGRES_DB") <> "_test",
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn
