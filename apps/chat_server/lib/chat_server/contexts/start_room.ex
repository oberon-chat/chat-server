defmodule ChatServer.StartRoom do
  require Logger

  alias ChatPubSub.Presence
  alias ChatServer.Event
  alias ChatServer.Room

  def call(room) do
    Logger.info "Starting room #{room.name} (#{room.id})"

    with {:ok, pid} <- Room.start(room.name),
         :ok <- broadcast_start(room, pid),
         :ok <- track_room(room, pid) do
      {:ok, pid}
    else
      _ -> nil
    end
  end

  defp broadcast_start(room, pid) do
    event = %Event.RoomStarted{pid: pid, room: room}

    ChatPubSub.broadcast! "rooms", "room:started", event
  end

  defp track_room(room, pid) do
    Presence.track(pid, "rooms", room.name, %{
      name: room.name,
      last_message: nil
    })

    Presence.track(pid, "room_pids", room.name, %{
      name: room.name,
      pid: pid
    })

    :ok
  end
end
