# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ink.Repo.insert!(%Ink.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ChatWebhook.Callback
alias ChatWebhook.Repo

Repo.insert!(%Callback{
  user_id: "844a3183-f286-4cb3-b2e3-88cacbc80173",
  name: "Test Slack Webhook",
  description: "Webhook callback for testing Slack integration",
  topics: ["rooms"],
  client_type: "slack",
  client_options: %{
    channels: ["#general", "#random"],
    token: "xoxa-236590168066-236068711649-236593689906-4c6063871f3bfea559428b5eaeb253e9"
  }
})

Repo.insert!(%Callback{
  user_id: "844a3183-f286-4cb3-b2e3-88cacbc80173",
  name: "Test HTTP Webhook",
  description: "Webhook callback for testing HTTP integration",
  topics: ["rooms"],
  client_type: "http",
  client_options: %{
    uri: "http://chat.dev/webhook/callback"
  }
})
