defmodule ChatServer.TrackSupportRooms do
  @moduledoc """
  Tracks public-facing information about support room processes using Presence
  """

  require Logger

  alias ChatPubSub.Presence
  alias ChatServer.TrackRooms

  @presence_key "support_rooms"

  # Queries

  def list, do: Presence.list(@presence_key)

  def get_pid(room), do: TrackRooms.get_pid(room)

  # Mutations

  def track(pid, %{type: "support"} = room) do
    case Map.get(list(), key(room)) do
      nil ->
        Presence.track(pid, @presence_key, key(room), %{
          slug: room.slug
        })
      _data ->
        Logger.warn "Support room already tracked #{room.slug}" <> inspect(pid)
        :error
    end
  end
  def track(_pid, _room), do: :error

  def update(room, values), do: update(get_pid(room), room, values)
  def update(pid, room, values) do
    Presence.update(pid, @presence_key, key(room), fn (meta) ->
      Map.merge(meta, values)
    end)
  end

  # Private Helpers

  defp key(room), do: room.slug
end
