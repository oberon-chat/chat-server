defmodule ChatWebsocket.RoomsChannel do
  use Phoenix.Channel

  alias ChatPubSub.Presence
  alias ChatServer.Schema
  alias ChatServer.Room

  def join("rooms", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list("rooms")

    {:noreply, socket}
  end

  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end

  def handle_in("rooms:create", room, socket) do
    find_or_start_room(room)

    {:noreply, socket}
  end

  defp find_or_start_room(name) do
    case Presence.list("room_pids")[name] do
      nil ->
        with {:ok, room} <- Schema.Room.get_or_create_by(:name, name, %{name: name}),
             {:ok, pid} <- Room.start(room.name),
             :ok <- broadcast_creation(room.name),
             :ok <- track_room(room.name, pid) do
          pid
        end
      %{metas: [%{pid: pid}]} ->
        pid
    end
  end

  defp broadcast_creation(room) do
    ChatPubSub.broadcast! "rooms", "room:created", %{room: room}
  end

  defp track_room(room, pid) do
    Presence.track(pid, "rooms", room, %{
      name: room,
      last_message: nil
    })

    Presence.track(pid, "room_pids", room, %{
      name: room,
      pid: pid
    })

    :ok
  end
end
