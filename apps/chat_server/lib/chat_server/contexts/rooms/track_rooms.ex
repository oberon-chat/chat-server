defmodule ChatServer.TrackRooms do
  require Logger

  alias ChatPubSub.Presence

  @presence_key "rooms"

  def track(pid, room) do
    case get_room_pid(key(room)) do
      nil ->
        Presence.track(pid, @presence_key, key(room), %{
          id: room.id,
          name: room.name,
          pid: Util.Pid.serialize(pid)
        })
      _existing_pid ->
        Logger.warn "Room already exists " <> inspect(pid)
        :error
    end
  end

  def list, do: Presence.list(@presence_key)

  def get_pid(room), do: get_room_pid(key(room))

  def update(room, values), do: update(get_pid(room), room, values)
  def update(pid, room, values) do
    Presence.update(pid, @presence_key, key(room), fn (meta) ->
      Map.merge(meta, values)
    end)
  end

  defp key(room), do: room.name

  defp get_room_pid(key) do
    case Presence.list(@presence_key)[key] do
      %{metas: [%{pid: pid}]} ->
        Util.Pid.deserialize(pid)
      %{metas: metas} ->
        Logger.warn "Multiple rooms created " <> inspect(metas)
        Util.Pid.deserialize(hd(metas) |> Map.get(:pid))
      _ ->
        nil
    end
  end
end
