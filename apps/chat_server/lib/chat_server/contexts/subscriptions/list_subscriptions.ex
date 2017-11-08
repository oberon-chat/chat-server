defmodule ChatServer.ListSubscriptions do
  alias ChatServer.Repo
  alias ChatServer.Schema

  def call(%Schema.Room{} = room) do
    Repo.preload(room, [:subscriptions]).subscriptions
    |> Repo.preload([:room, :user])
    |> omit([:state, :viewed_at, :updated_at])
  end
  def call(%Schema.User{} = user) do
    Repo.preload(user, [:subscriptions]).subscriptions
    |> Repo.preload([:room, :user])
  end

  defp omit(records, values) do
    records
    |> Enum.map(&Map.drop(&1, values))
  end
end
