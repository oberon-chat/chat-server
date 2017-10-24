defmodule ChatServer.DeleteMessage do
  alias ChatServer.Schema

  def call(user, params) do
    # TODO: verify user is still allowed to make updates in room

    with {:ok, record} <- get_record(params),
         true <- owner?(record, user),
         {:ok, record} <- delete_record(record),
         :ok <- broadcast_delete(record) do
      {:ok, record}
    else
      _ -> {:error, "Error deleting message"}
    end
  end

  defp get_record(params) do
    id = Map.get(params, "id")

    case Schema.Message.get(id) do
      nil -> {:error, "Record not found"}
      record -> {:ok, record}
    end
  end

  defp owner?(record, user) do
    user.id == record.user_id
  end

  defp delete_record(record) do
    Schema.Message.delete(record)
  end

  defp broadcast_delete(record) do
    ChatPubSub.broadcast! "events", "message:deleted", record
  end
end
