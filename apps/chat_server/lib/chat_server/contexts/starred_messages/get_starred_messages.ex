defmodule ChatServer.GetStarredMessages do
  alias ChatServer.Schema

  def call(user) do
    %{starred_messages: get_starred_messages(user)}
  end

  defp get_starred_messages(user) do
    Schema.StarredMessage.get_by_user(user)
  end
end
