use Mix.Config

config :chat_server, ChatServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("CHAT_SERVER_POSTGRES_HOST"),
  username: System.get_env("CHAT_SERVER_POSTGRES_USER"),
  password: System.get_env("CHAT_SERVER_POSTGRES_PASS"),
  database: System.get_env("CHAT_SERVER_POSTGRES_DB"),
  pool_size: 10

config :logger, level: :info
