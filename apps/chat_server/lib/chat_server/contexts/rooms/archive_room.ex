defmodule ChatServer.ArchiveRoom do
  require Logger

  alias ChatServer.Schema

  defmodule State do
    @derive {Poison.Encoder, only: [room: [:id, :slug, :name]]}

    defstruct [:room]
  end

  def call(params \\ %{}, _user) do
    Logger.info "Archiving room " <> inspect(params)

    # TODO verify user is allowed to archive room of that type

    with {:ok, record} <- archive_room(params),
         :ok <- broadcast_archive(record) do
      {:ok, record}
    else
      _ -> :error
    end
  end

  defp archive_room(params) do
    changeset = params
    |> Map.take(["id", "name"])
    |> Map.put(:status, "archived")

    Schema.Room.update(params, changeset)
  end

  defp broadcast_archive(room) do
    event = %State{room: room}

    ChatPubSub.broadcast! "events", "room:archived", event
  end
end
