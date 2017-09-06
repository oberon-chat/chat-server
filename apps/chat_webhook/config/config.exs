# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :chat_webhook, ecto_repos: [ChatWebhook.Repo]

config :chat_webhook, :slack_client,
  uri: "https://slack.com/api/chat.postMessage"

import_config "#{Mix.env}.exs"
