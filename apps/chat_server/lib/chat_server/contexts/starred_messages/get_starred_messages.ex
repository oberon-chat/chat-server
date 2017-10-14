defmodule GetStarredMessages do
  alias ChatServer.Schema

  def call(user) do
    #TODO how to handle calling user? we wont have any params here
    #like we do with similar actions like in messages/get_room_messages
    # with user <- get_starred_messages(user)
    #   {}
    #what would be the error condition?
    get_starred_messages(user)
  end

  defp get_starred_messages(user) do
    Schema.StarredMessage.get_starred_messages(user)
  end
end
