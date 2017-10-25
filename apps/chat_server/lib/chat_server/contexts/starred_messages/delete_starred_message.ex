defmodule ChatServer.DeleteStarredMessage do
  require Logger

  alias ChatServer.Schema

  def call(message_id, user) do
    message = Schema.Message.get(message_id)
    starred_message = Schema.StarredMessage.find_by_message_and_user(message, user)
    star_id = Map.get(starred_message, :id)

    with {:ok, _record} <- Schema.StarredMessage.delete(starred_message) do
        {:ok, %{id: star_id}}
    else
      error ->
        Logger.debug "Error deleting starred message" <> inspect(error)
          {:error, "Error deleting starred message"}
    end
  end
end
