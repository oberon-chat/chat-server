defmodule ChatServer.CreateStarredMessage do
  require Logger

  alias ChatServer.BroadcastEvent
  alias ChatServer.Schema

  def call(message_id, user) do
    with message <- Schema.Message.get(message_id),
         {:ok, record} <- create_record(message, user),
         :ok <- broadcast_event(record) do
      {:ok, Schema.StarredMessage.preload(record, [:message, :user])}
    else
      error ->
        Logger.debug "Error starring message " <> inspect(error)
        {:error, "Error starring message"}
    end
  end

  defp create_record(message, user) do
    message
    |> filter_params(user)
    |> Schema.StarredMessage.create
  end

  defp filter_params(message, user) do
    %{}
    |> Map.put("message_id", Map.get(message, :id, nil))
    |> Map.put("user_id", Map.get(user, :id, nil))
  end

  defp broadcast_event(starred_message) do
    BroadcastEvent.call("starred_message:created", starred_message)
  end
end
