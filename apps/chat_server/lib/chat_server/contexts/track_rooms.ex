defmodule ChatServer.TrackRooms do
  alias ChatPubSub.Presence

  @presence_rooms_key "rooms"
  @presence_pids_key "room_pids"

  def track(pid, room) do
    Presence.track(pid, @presence_rooms_key, key(room), %{
      name: room.name,
      last_message: nil
    })
  end

  def track_pid(pid, room) do
    Presence.track(pid, @presence_pids_key, key(room), %{
      name: room.name,
      pid: pid
    })
  end

  def list, do: Presence.list(@presence_rooms_key)

  def get_pid(room), do: get_room_pid(key(room))

  def update(room, values), do: update(get_pid(room), room, values)

  def update(pid, room, values) do
    Presence.update(pid, @presence_rooms_key, key(room), fn (meta) ->
      Map.merge(meta, values)
    end)
  end

  defp key(room), do: room.name

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
