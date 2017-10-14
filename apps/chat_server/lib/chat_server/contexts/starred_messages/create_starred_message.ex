defmodule ChatServer.CreateStarredMessage do
  require Logger

  alias ChatServer.Schema

  def call(message, user) do

    with {:ok, record} <- create_record(message, user) do
          # :ok <- push_create(record) do
        # {:ok, Schema.StarredMessage.preload(record, [:message, :user])}
        {:ok, Schema.StarredMessage.preload(record, [:message, :user])}
    else
      error ->
        Logger.debug "Error starring message " <> inspect(error)
          {:error, "Error starring message"}
    end
  end

  defp create_record(message, user) do
    Schema.StarredMessage.create(user_id: user.id, message_id: message.id)
  end
end  # TODO do a i need a push_create or broadcast_create method here?
