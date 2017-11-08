defmodule ChatServer.DeleteMessage do
  alias ChatServer.BroadcastEvent
  alias ChatServer.Schema

  def call(user, params) do
    # TODO: verify user is still allowed to make updates in room

    with {:ok, record} <- get_record(params),
         true <- owner?(user, record),
         {:ok, record} <- delete_record(record),
         :ok <- broadcast_event(record) do
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

  defp owner?(user, record) do
    user.id == record.user_id
  end

  defp delete_record(record) do
    Schema.Message.delete(record)
  end

  defp broadcast_event(message) do
    BroadcastEvent.call("message:deleted", message)
  end
end
