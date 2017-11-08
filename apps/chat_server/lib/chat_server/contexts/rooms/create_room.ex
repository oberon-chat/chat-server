defmodule ChatServer.CreateRoom do
  require Logger

  alias ChatServer.BroadcastEvent
  alias ChatServer.Schema

  def call(_user, params \\ %{}) do
    Logger.info "Creating room " <> inspect(params)

    # TODO verify user is allowed to create room of that type

    with {:ok, record} <- create_record(params),
         :ok <- broadcast_event(record) do
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

  defp broadcast_event(room) do
    BroadcastEvent.call("room:created", room)
  end
end
