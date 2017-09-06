use Mix.Config

config :chat_callback, ChatCallback.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("CHAT_CALLBACK_POSTGRES_HOST"),
  username: System.get_env("CHAT_CALLBACK_POSTGRES_USER"),
  password: System.get_env("CHAT_CALLBACK_POSTGRES_PASS"),
  database: System.get_env("CHAT_CALLBACK_POSTGRES_DB") <> "_test",
  pool: Ecto.Adapters.SQL.Sandbox
