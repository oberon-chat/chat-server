defmodule ChatServer.StartRoom do
  require Logger

  alias ChatServer.Room

  defmodule State do
    @derive {Poison.Encoder, only: [room: [:id, :slug, :name]]}

    defstruct [:pid, :room]
  end

  def call(room) do
    Logger.info "Starting room #{room.name} (#{room.id})"

    with {:ok, pid} <- Room.start(room),
         :ok <- broadcast_start(room, pid) do
      {:ok, pid}
    else
      _ -> nil
    end
  end

  defp broadcast_start(room, pid) do
    event = %State{pid: pid, room: room}

    ChatPubSub.broadcast! "events", "room:started", event
  end
end
