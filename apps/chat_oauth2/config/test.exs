use Mix.Config

config :chat_oauth2, ChatOAuth2.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("CHAT_OAUTH2_POSTGRES_HOST"),
  username: System.get_env("CHAT_OAUTH2_POSTGRES_USER"),
  password: System.get_env("CHAT_OAUTH2_POSTGRES_PASS"),
  database: System.get_env("CHAT_OAUTH2_POSTGRES_DB") <> "_test",
  pool: Ecto.Adapters.SQL.Sandbox
