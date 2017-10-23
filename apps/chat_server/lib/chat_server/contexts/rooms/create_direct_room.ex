defmodule ChatServer.CreateDirectRoom do
  import Ecto.Query

  alias ChatServer.CreateSubscription
  alias ChatServer.GetDirectRoom
  alias ChatServer.GetUser
  alias ChatServer.Repo
  alias ChatServer.Schema

  def call(primary_user, params \\ %{}) do
    # TODO verify user is allowed to create direct room

    with {:ok, secondary_user} <- GetUser.call(Map.get(params, "user_id")),
         {:error, _} <- GetDirectRoom.call(primary_user, secondary_user),
         {:ok, record} <- create_record(primary_user, secondary_user),
         {:ok, subscription} <- create_primary_subscription(primary_user, record),
         {:ok, _} <- create_secondary_subscription(secondary_user, record) do
      {:ok, record, subscription}
    else
      _ -> {:error, "Error creating room"}
    end
  end

  defp create_record(primary_user, secondary_user) do
    create_params(primary_user, secondary_user)
    |> Schema.Room.create
  end

  defp create_params(primary_user, secondary_user) do
    %{
      name: "#{primary_user.name} and #{secondary_user.name}",
      slug: Ecto.UUID.generate,
      type: "direct"
    }
  end

  def create_primary_subscription(user, room) do
    CreateSubscription.call(user, room.id, state: "open")
  end

  def create_secondary_subscription(user, room) do
    CreateSubscription.call(user, room.id, state: "closed")
  end
end
