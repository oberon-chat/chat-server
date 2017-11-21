defmodule ChatServer.UpdateRoom do
  require Logger

  alias ChatServer.BroadcastEvent
  alias ChatServer.Schema

  defmodule State do
    @derive {Poison.Encoder, only: [room: [:id, :slug, :name]]}

    defstruct [:room]
  end

  def call(room_id, _user, state) do
    Logger.info "Updating room " <> inspect(room_id)

    # TODO verify user is allowed to update room of that type

    with {:ok, record} <- GetRoom(room_id),
         {:ok, record} <- update(record, state),
          :ok <- broadcast_update(record) do
         {:ok, record}
    else
      _ -> :error
    end
  end

  defp update(params, state) do
    changeset = params
    |> Map.take([:id, :name])
    |> Map.put(:state, state)

    Schema.Room.update(params, changeset)
  end

  defp broadcast_update(room) do
    BroadcastEvent.call("room:updated", room)
  end
end
