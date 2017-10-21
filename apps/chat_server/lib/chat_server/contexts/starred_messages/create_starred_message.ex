defmodule ChatServer.CreateStarredMessage do
  require Logger

  alias ChatServer.Schema

  def call(message_id, user) do
    message = Schema.Message.get(message_id)
    with {:ok, record} <- Schema.StarredMessage.create(%{user: user, message: message}) do
        {:ok, Schema.StarredMessage.preload(record, [:message, :user])}
    else
      error ->
        Logger.debug "Error starring message " <> inspect(error)
          {:error, "Error starring message"}
    end
  end

end
