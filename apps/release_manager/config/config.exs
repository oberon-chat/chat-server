use Mix.Config

config :release_manager, apps: [
  chat_oauth2: ChatServer.OAuth2,
  chat_server: ChatServer.Repo,
  chat_webhook: ChatWebhook.Repo
]
