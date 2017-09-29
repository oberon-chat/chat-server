defmodule ChatServer.CreateRoom do
  require Logger

  alias ChatServer.Event
  alias ChatServer.Schema

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
    event = %Event.RoomCreated{room: room}

    ChatPubSub.broadcast! "rooms", "room:created", event
  end
end
