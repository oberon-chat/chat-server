use Mix.Config

config :release_manager, apps: [
  chat_oauth2: ChatOAuth2.Repo,
  chat_server: ChatServer.Repo,
  chat_webhook: ChatWebhook.Repo
]
