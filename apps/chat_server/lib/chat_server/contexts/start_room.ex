defmodule ChatServer.StartRoom do
  require Logger

  alias ChatServer.Event
  alias ChatServer.Room
  alias ChatServer.TrackRooms

  def call(room) do
    Logger.info "Starting room #{room.name} (#{room.id})"

    with {:ok, pid} <- Room.start(room),
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
    with {:ok, _} <- TrackRooms.track(pid, room),
         {:ok, _} <- TrackRooms.track_pid(pid, room) do
      :ok
    else
      _ -> :error
    end
  end
end
