defmodule ChatServer.TrackRooms do
  @moduledoc """
  Tracks internal-facing information about room processes using Presence.
  """

  require Logger

  alias ChatPubSub.Presence

  @presence_key "internal:room_pids"

  # Queries

  def list, do: Presence.list(@presence_key)

  def get_pid(room), do: get_room_pid(key(room))

  # Mutations

  def track(pid, room) do
    case get_room_pid(key(room)) do
      nil ->
        Presence.track(pid, @presence_key, key(room), %{
          id: room.id,
          slug: room.slug,
          pid: pid
        })
      _existing_pid ->
        Logger.warn "Room already exists #{room.slug}" <> inspect(pid)
        :error
    end
  end

  def update(room, values), do: update(get_pid(room), room, values)
  def update(pid, room, values) do
    Presence.update(pid, @presence_key, key(room), fn (meta) ->
      Map.merge(meta, values)
    end)
  end

  # Private Helpers

  defp key(room), do: room.slug

  defp get_room_pid(key) do
    case Presence.list(@presence_key)[key] do
      %{metas: [%{pid: pid}]} ->
        pid
      %{metas: metas} ->
        Logger.warn "Multiple rooms created " <> inspect(metas)
        Map.get(hd(metas), :pid)
      _ ->
        nil
    end
  end
end
