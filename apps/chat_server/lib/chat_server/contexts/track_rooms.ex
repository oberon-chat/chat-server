defmodule ChatServer.TrackRooms do
  alias ChatPubSub.Presence

  @presence_rooms_key "rooms"
  @presence_pids_key "room_pids"

  def track(pid, room) do
    Presence.track(pid, @presence_rooms_key, room.name, %{
      name: room.name,
      last_message: nil
    })
  end

  def track_pid(pid, room) do
    Presence.track(pid, @presence_pids_key, room.name, %{
      name: room.name,
      pid: pid
    })
  end

  def list, do: Presence.list(@presence_rooms_key)

  def get_pid(key), do: get_room_pid(key)

  defp get_room_pid(key, attempt \\ 1) do
    if attempt <= 4 do
      case Presence.list(@presence_pids_key)[key] do
        nil ->
          :timer.sleep(50)
          get_room_pid(key, attempt + 1)
        %{metas: [%{pid: pid}]} ->
          pid
      end
    else
      nil
    end
  end
end

