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

alias ChatCallback.Record
alias ChatCallback.Repo

Repo.insert!(%Record{
  user_id: "844a3183-f286-4cb3-b2e3-88cacbc80173",
  name: "Test Slack Callback",
  description: "Callback record for testing Slack integration",
  topics: ["rooms"],
  client_type: "slack",
  client_options: %{
    channels: ["#general", "#random"],
    token: "xoxa-236590168066-236068711649-236593689906-4c6063871f3bfea559428b5eaeb253e9"
  }
})

Repo.insert!(%Record{
  user_id: "844a3183-f286-4cb3-b2e3-88cacbc80173",
  name: "Test HTTP Callback",
  description: "Callback record for testing HTTP integration",
  topics: ["rooms"],
  client_type: "http",
  client_options: %{
    uri: "https://chat.dev/callbacks"
  }
})
