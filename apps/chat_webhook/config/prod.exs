use Mix.Config

config :chat_webhook, ChatWebhook.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("CHAT_WEBHOOK_POSTGRES_HOST"),
  username: System.get_env("CHAT_WEBHOOK_POSTGRES_USER"),
  password: System.get_env("CHAT_WEBHOOK_POSTGRES_PASS"),
  database: System.get_env("CHAT_WEBHOOK_POSTGRES_DB"),
  pool_size: 15

config :logger, level: :info
