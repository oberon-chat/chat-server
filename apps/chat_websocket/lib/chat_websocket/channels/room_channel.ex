defmodule ChatWebsocket.RoomChannel do
  use Phoenix.Channel

  alias ChatServer.Room
  alias ChatServer.Schema
  alias ChatServer.CreateMessage
  alias ChatServer.CreateSubscription
  alias ChatServer.DeleteMessage
  alias ChatServer.TrackRoomUsers
  alias ChatServer.UpdateMessage

  def join("room:" <> slug, _, socket) do
    case Schema.Room.get_by(slug: slug) do
      nil -> {:error, "Room #{slug} does not exist"}
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

    push socket, "users:state", TrackRoomUsers.list(socket)
    push socket, "messages:list", Room.get_messages(socket)

    {:noreply, socket}
  end

  def handle_in("room:subscribe", _params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, subscription} <- CreateSubscription.call(user, room) do
      push socket, "room:subscribed", subscription
    end

    {:noreply, socket}
  end

  def handle_in("message:create", params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, record} <- CreateMessage.call(params, room, user),
         {:ok, _} <- Room.create_message(socket, record) do
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

  # Filters

  intercept ["presence_diff"]

  def handle_out("presence_diff", msg, socket) do
    push socket, "users:diff", msg

    {:noreply, socket}
  end
  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end
end
