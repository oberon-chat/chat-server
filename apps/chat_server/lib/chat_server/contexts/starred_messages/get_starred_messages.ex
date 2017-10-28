defmodule ChatServer.GetStarredMessages do
  alias ChatServer.Schema

  def call(%Schema.User{} = user) do
    case Schema.StarredMessage.get_by_user(user) do
      _starred_messages -> {:ok, _starred_messages}
    end
  end
end
