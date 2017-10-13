defmodule ChatServer.CreateSubscription do
  alias ChatServer.Repo
  alias ChatServer.Schema

  # TODO: confirm user is allowed to subscribe to rooms
  # TODO: confirm room allows new subscriptions

  def call(user, room_id) when is_bitstring(room_id) do
    room = Repo.get(Schema.Room, room_id)
    call(user, room)
  end
  def call(user_id, room) when is_bitstring(user_id) do
    user = Repo.get(Schema.User, user_id)
    call(user, room)
  end
  def call(%Schema.User{} = user, %Schema.Room{} = room) do
    params = %{room: room, user: user}

    case Schema.Subscription.create(params) do
      {:ok, subscription} ->
        {:ok, Repo.preload(subscription, [:room])}
      _ ->
        {:eror, "Error creating subscription"}
    end
  end
end
