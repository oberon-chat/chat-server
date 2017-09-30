defmodule ChatServer.TrackRooms do
  alias ChatPubSub.Presence

  defmodule State do
    @derive {Poison.Encoder, only: [:last_message, room: [:id, :slug, :name]]}

    defstruct [:last_message, :name, :pid]
  end

  @presence_key "rooms"

  def track(pid, room) do
    Presence.track(pid, @presence_key, key(room), %State{
      name: room.name,
      last_message: nil,
      pid: pid
    })
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

  defp get_room_pid(key, attempt \\ 1) do
    if attempt <= 4 do
      case Presence.list(@presence_key)[key] do
        nil ->
          :timer.sleep(50)
          get_room_pid(key, attempt + 1)
        %{metas: [%State{pid: pid}]} ->
          pid
      end
    else
      nil
    end
  end
end
