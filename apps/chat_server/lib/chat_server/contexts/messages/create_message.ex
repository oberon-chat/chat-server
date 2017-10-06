defmodule ChatServer.CreateMessage do
  require Logger

  alias ChatServer.Schema

  @allowed_params ["body"]

  def call(params, room, user) do
    # TODO: verify user is allowed to post message to room

    with {:ok, record} <- create_record(params, room, user),
         :ok <- broadcast_create(record) do
      {:ok, Schema.Message.preload(record, [:room, :user])}
    else
      error ->
        Logger.debug "Error creating message " <> inspect(error)
        {:error, "Error creating message"}
    end
  end

  defp create_record(params, room, user) do
    params
    |> filter_params(room, user)
    |> Schema.Message.create
  end

  defp filter_params(params, room, user) do
    params
    |> Map.take(@allowed_params)
    |> Map.put("room_id", Map.get(room, :id, nil))
    |> Map.put("user_id", Map.get(user, :id, nil))
  end

  defp broadcast_create(record) do
    ChatPubSub.broadcast! "events", "message:created", record
  end
end
