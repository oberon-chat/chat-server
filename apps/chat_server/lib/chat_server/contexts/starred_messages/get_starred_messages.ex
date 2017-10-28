defmodule ChatServer.GetStarredMessages do
  alias ChatServer.Schema

  def call(%Schema.User{} = user) do
    case Schema.StarredMessage.get_by_user(user) do
      starred_messages -> {:ok, starred_messages}
    end
  end
end
