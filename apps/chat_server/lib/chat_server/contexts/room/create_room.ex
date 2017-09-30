defmodule ChatServer.CreateRoom do
  require Logger

  alias ChatServer.Schema

  defmodule State do
    @derive {Poison.Encoder, only: [room: [:id, :slug, :name]]}

    defstruct [:room]
  end

  def call(params \\ %{}) do
    Logger.info "Creating room " <> inspect(params)

    with {:ok, record} <- create_record(params),
         :ok <- broadcast_creation(record) do
      {:ok, record}
    else
      _ -> :error
    end
  end

  defp create_record(params) do
    name = Map.get(params, :name)

    Schema.Room.get_or_create_by(:name, name, params)
  end

  defp broadcast_creation(room) do
    event = %State{room: room}

    ChatPubSub.broadcast! "events", "room:created", event
  end
end
