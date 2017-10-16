defmodule ChatServer.DeleteStarredMessage do
  alias ChatServer.Schema

  def call(params, user, message) do
    with record <- get_record(user, message),
         {:ok, _record} <- delete_record(record) do
      {:ok, Map.get(params,"id")}
    else
      _ -> {:error, "Error deleting starred message"}
    end
  end

  defp get_record(user, message) do
    Schema.StarredMessage.find_by_message_and_user(user, message)
  end

  defp delete_record(record) do
    Schema.StarredMessage.delete(record)
  end
end
