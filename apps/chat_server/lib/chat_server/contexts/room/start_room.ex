defmodule ChatServer.StartRoom do
  require Logger

  alias ChatServer.Event
  alias ChatServer.Room
  alias ChatServer.TrackRooms

  def call(room) do
    Logger.info "Starting room #{room.name} (#{room.id})"

    with {:ok, pid} <- Room.start(room),
         {:ok, _} <- TrackRooms.track(pid, room),
         :ok <- broadcast_start(room, pid) do
      {:ok, pid}
    else
      _ -> nil
    end
  end

  defp broadcast_start(room, pid) do
    event = %Event.RoomStarted{pid: pid, room: room}

    ChatPubSub.broadcast! "events", "room:started", event
  end
end
