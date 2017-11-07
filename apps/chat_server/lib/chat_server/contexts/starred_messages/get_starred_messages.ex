defmodule ChatServer.GetStarredMessages do
  alias ChatServer.Schema

  def call(%Schema.User{} = user) do
    Schema.StarredMessage.get_by_user(user)
  end
end
