defmodule ChatWebsocket.RoomChannel do
  use Phoenix.Channel

  alias ChatServer.Room
  alias ChatServer.Schema
  alias ChatServer.TrackRooms
  alias ChatServer.TrackRoomUsers

  def join("room:" <> name, _, socket) do
    case Schema.Room.get_by(:name, name) do
      nil -> {:error, "Room #{name} does not exist"}
      room ->
        socket = socket
          |> assign(:room, room)
          |> assign(:room_pid, TrackRooms.get_pid(room))

        send self(), :after_join

        {:ok, assign(socket, :room, room)}
    end
  end

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

  def handle_in("message:create", message, socket) do
    with {:ok, message} <- Schema.Message.create(%{ body: message }) do
      %{
        room: room,
        user: %{
          name: name
        }
      } = socket.assigns

      message = %{
        id: message.id,
        user: name,
        body: message.body,
        edited: message.edited,
        room: room.name,
        timestamp: message.inserted_at
      }

      TrackRooms.update(room, %{last_message: message})

      Room.create_message(socket, message)
      broadcast! socket, "message:created", message
    end

    {:noreply, socket}
  end

  def handle_in("message:update", message, socket) do
    with true <- Map.get(message, "user") == socket.assigns.user.name do
      %{message: updated} = Room.update_message(socket, message)

      broadcast! socket, "message:update", updated
    end

    {:noreply, socket}
  end

  def handle_in("message:delete", message, socket) do
    with true <- Map.get(message, "user") == socket.assigns.user.name,
         {:ok, _} <- Room.delete_message(socket, message) do
      broadcast! socket, "message:delete", message
    end

    {:noreply, socket}
  end
end
