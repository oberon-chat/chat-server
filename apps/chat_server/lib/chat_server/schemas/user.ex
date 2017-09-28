defmodule ChatServer.Schema.User do
  use ChatServer.Schema

  schema "users" do
    field :name, :string

    timestamps()
  end
end

