defmodule ChatServer.CreateRoom do
  require Logger

  alias ChatServer.Schema

  defmodule State do
    @derive {Poison.Encoder, only: [room: [:id, :slug, :name]]}

    defstruct [:room]
  end

  def call(_user, params \\ %{}) do
    Logger.info "Creating room " <> inspect(params)

    # TODO verify user is allowed to create room of that type

    with {:ok, record} <- create_record(params),
         :ok <- broadcast_creation(record) do
      {:ok, record}
    else
      _ -> :error
    end
  end

  defp create_record(params) do
    params
    |> Map.take(["name", "type"])
    |> Schema.Room.create
  end

  defp broadcast_creation(room) do
    event = %State{room: room}

    ChatPubSub.broadcast! "events", "room:created", event
  end
end
