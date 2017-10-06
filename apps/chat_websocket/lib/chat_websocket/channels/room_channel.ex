defmodule ChatWebsocket.RoomChannel do
  use Phoenix.Channel

  alias ChatServer.Room
  alias ChatServer.Schema
  alias ChatServer.CreateMessage
  alias ChatServer.DeleteMessage
  alias ChatServer.TrackRooms
  alias ChatServer.TrackRoomUsers
  alias ChatServer.UpdateMessage

  def join("room:" <> name, _, socket) do
    case Schema.Room.get_by(name: name) do
      nil -> {:error, "Room #{name} does not exist"}
      room -> join_room(socket, room)
    end
  end

  defp join_room(socket, room) do
    send self(), :after_join
    {:ok, assign(socket, :room, room)}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    TrackRoomUsers.track(socket, socket.assigns.user)

    push socket, "presence_state", TrackRoomUsers.list(socket)
    push socket, "message_state", Room.get_messages(socket)

    {:noreply, socket}
  end

  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end

  def handle_in("message:create", params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, record} <- CreateMessage.call(params, room, user),
         {:ok, _} <- Room.create_message(socket, record) do
      TrackRooms.update(room, %{last_message: record})
      broadcast! socket, "message:created", record
    end

    {:noreply, socket}
  end

  def handle_in("message:update", params, socket) do
    %{user: user} = socket.assigns

    with {:ok, record} <- UpdateMessage.call(params, user),
         {:ok, message} <- Room.update_message(socket, record) do
      broadcast! socket, "message:updated", message
    end

    {:noreply, socket}
  end

  def handle_in("message:delete", params, socket) do
    %{user: user} = socket.assigns

    with {:ok, _} <- DeleteMessage.call(params, user),
         {:ok, message} <- Room.delete_message(socket, params) do
      broadcast! socket, "message:deleted", message
    end

    {:noreply, socket}
  end
end
