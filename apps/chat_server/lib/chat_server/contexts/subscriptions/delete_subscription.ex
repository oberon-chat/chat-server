defmodule ChatServer.DeleteSubscription do
  alias ChatServer.Repo
  alias ChatServer.Schema

  # TODO: confirm user is allowed to unsubscribe from room (direct message)

  def call(user, room_id) when is_bitstring(room_id) do
    room = Repo.get(Schema.Room, room_id)
    call(user, room)
  end
  def call(user_id, room) when is_bitstring(user_id) do
    user = Repo.get(Schema.User, user_id)
    call(user, room)
  end
  def call(%Schema.User{} = user, %Schema.Room{} = room) do
    with {:ok, record} <- get_record(user, room),
         {:ok, _} <- delete_record(record) do
      {:ok, record}
    else
      _ -> {:error, "Error deleting message"}
    end
  end

  defp get_record(user, room) do
    params = %{room_id: room.id, user_id: user.id}

    case Schema.Subscription.get_by(params) do
      nil -> {:error, "Record not found"}
      record -> {:ok, record}
    end
  end

  defp delete_record(record) do
    Schema.Subscription.delete(record)
  end
end
