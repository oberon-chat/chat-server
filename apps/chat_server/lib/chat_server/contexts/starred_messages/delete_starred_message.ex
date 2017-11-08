defmodule ChatServer.DeleteStarredMessage do
  require Logger

  alias ChatServer.BroadcastEvent
  alias ChatServer.Schema

  def call(message_id, user) do
    with message <- Schema.Message.get(message_id),
         starred_message <- Schema.StarredMessage.find_by_message_and_user(message, user),
         {:ok, _record} <- Schema.StarredMessage.delete(starred_message),
         :ok <- broadcast_event(starred_message) do
      {:ok, %{id: starred_message.id}}
    else
      error ->
        Logger.debug "Error deleting starred message" <> inspect(error)
        {:error, "Error deleting starred message"}
    end
  end

  defp broadcast_event(starred_message) do
    BroadcastEvent.call("starred_message:deleted", starred_message)
  end
end
