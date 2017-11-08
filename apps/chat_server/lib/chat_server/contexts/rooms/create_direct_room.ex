defmodule ChatServer.CreateDirectRoom do
  alias ChatServer.BroadcastEvent
  alias ChatServer.CreateSubscription
  alias ChatServer.GetDirectRoom
  alias ChatServer.GetUser
  alias ChatServer.Schema

  def call(primary_user, params \\ %{}) do
    # TODO verify user is allowed to create direct room

    with {:ok, secondary_user} <- GetUser.call(Map.get(params, "user_id")),
         {:error, _} <- GetDirectRoom.call(primary_user, secondary_user),
         {:ok, record} <- create_record(primary_user, secondary_user),
         {:ok, primary_subscription} <- create_primary_subscription(primary_user, record),
         {:ok, secondary_subscription} <- create_secondary_subscription(secondary_user, record),
         :ok <- broadcast_event(record) do
      {:ok, %{
        primary_subscription: primary_subscription,
        primary_user: primary_user,
        record: record,
        secondary_subscription: secondary_subscription,
        secondary_user: secondary_user,
      }}
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

  defp broadcast_event(room) do
    BroadcastEvent.call("room:direct:created", room)
  end
end
