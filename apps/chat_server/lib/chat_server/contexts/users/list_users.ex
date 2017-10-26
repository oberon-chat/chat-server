defmodule ChatServer.ListUsers do
  alias ChatServer.Schema

  def call(_user) do
    # TODO: verify user is allowed to see list of users
    Schema.User.active
  end
end
