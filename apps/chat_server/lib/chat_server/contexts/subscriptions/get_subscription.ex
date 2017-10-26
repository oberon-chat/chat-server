defmodule ChatServer.GetSubscription do
  alias ChatServer.Schema

  def call(%Schema.User{} = user, %Schema.Room{} = room) do
    case Schema.Subscription.get_by(user_id: user.id, room_id: room.id) do
      nil -> {:error, "Subscription not found"}
      subscription -> {:ok, subscription}
    end
  end
end
