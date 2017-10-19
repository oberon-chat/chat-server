defmodule ChatServer.ListPublicRooms do
  alias ChatServer.Schema

  def call(_user) do
    # TODO: verify user is allowed to see list of rooms
    Schema.Room.by_type("public")
  end
end
