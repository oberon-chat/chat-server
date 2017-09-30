defmodule ChatServer.UpdateMessage do
  alias ChatServer.Schema

  @allowed_params ["body"]

  def call(params, user) do
    # TODO: verify user is still allowed to post message to room

    with record <- get_record(params),
         true <- owner?(record, user),
         {:ok, record} <- update_record(record, params),
         :ok <- broadcast_update(record) do
      {:ok, Schema.Message.public(record)}
    else
      _ -> {:error, "Error updating message"}
    end
  end

  defp get_record(params) do
    params
    |> Map.get("id")
    |> Schema.Message.get
  end

  defp owner?(record, user) do
    user.id == record.user_id
  end

  defp update_record(record, params) do
    Schema.Message.update(record, filter_params(params))
  end

  defp filter_params(params) do
    params
    |> Map.take(@allowed_params)
    |> Map.put("edited", true)
  end

  defp broadcast_update(record) do
    ChatPubSub.broadcast! "events", "message:updated", record
  end
end
