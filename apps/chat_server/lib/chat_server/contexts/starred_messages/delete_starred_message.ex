defmodule ChatServer.DeleteStarredMessage do
  alias ChatServer.Schema

  def call(params, user) do
    with record <- get_record(params) do
         delete_record(record)
        #  TODO do i want to broadcast or push this?
    end
  end

  defp get_record(params) do
    params
    |> Map.get("id")
    |> Schema.StarredMessage.get(:message_id)
  end

  defp delete_record(record) do
    Scheme.StarredMessage.delete(record)
  end
end
