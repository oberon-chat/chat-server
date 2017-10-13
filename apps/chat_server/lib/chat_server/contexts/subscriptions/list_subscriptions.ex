defmodule ChatServer.ListSubscriptions do
  alias ChatServer.Repo
  alias ChatServer.Schema

  def call(%Schema.User{} = user) do
    Repo.preload(user, [:subscriptions]).subscriptions
    |> Repo.preload([:room])
  end
end
