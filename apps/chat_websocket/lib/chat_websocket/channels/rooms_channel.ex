defmodule ChatWebsocket.RoomsChannel do
  use Phoenix.Channel

  alias ChatServer.CreateRoom
  alias ChatServer.StartRoom
  alias ChatServer.TrackRooms
  alias ChatServer.GetStarredMessages
  alias ChatServer.CreateStarredMessage

  def join("rooms", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", TrackRooms.list
    push socket, "starred_messages_state", GetStarredMessages.call(socket.assigns.user)

    {:noreply, socket}
  end

  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end

  def handle_in("rooms:create", name, socket) do
    case CreateRoom.call(%{name: name}) do
      {:ok, record} -> StartRoom.call(record)
      _ -> nil
    end

    {:noreply, socket}
  end

  def handle_in("starred_message:create", message_id, socket) do
    with {:ok, record} <- CreateStarredMessage.call(message_id, socket.assigns.user) do
      push socket, "starred_message:created", record
    end
  end
end
