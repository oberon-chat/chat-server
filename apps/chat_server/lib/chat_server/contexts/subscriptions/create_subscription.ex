defmodule ChatServer.CreateSubscription do
  alias ChatServer.Repo
  alias ChatServer.Schema

  def call(user, room_id) when is_bitstring(room_id) do
    room = Repo.get(Schema.Room, room_id)
    call(user, room)
  end
  def call(user_id, room) when is_bitstring(user_id) do
    user = Repo.get(Schema.User, user_id)
    call(user, room)
  end
  def call(%Schema.User{} = user, %Schema.Room{} = room) do
    user = Repo.preload(user, [:rooms])
    rooms = [room | user.rooms]
    params = %{rooms: rooms}

    case Schema.User.update_rooms(user, params) do
      {:ok, user} -> user
      _ -> false
    end
  end
end
