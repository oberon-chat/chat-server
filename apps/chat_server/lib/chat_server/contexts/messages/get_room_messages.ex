defmodule RoomMessages do
  alias ChatServer.Schema

  def call(params, user) do
    # TODO: verify user is subscribed to room

    with room <- get_room(params),
         {:ok, records} <- get_room_messages(room, params) do
      {:ok, Schema.Message.preload(records, [:room, :user])}
    else
      _ -> {:error, "Error getting room messages"}
    end
  end

  defp get_room(params) do
    params
    |> Map.get("room", %{})
    |> Map.get("id", nil)
    |> Schema.Room.get
  end

  defp get_room_messages(room, params) do
    Schema.Room.get_messages(room)
  end
end
