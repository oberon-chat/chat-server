# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :chat_oauth2, ecto_repos: [ChatOAuth2.Repo]

import_config "#{Mix.env}.exs"
