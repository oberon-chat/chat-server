defmodule ChatServer.Schema.Message do
  use ChatServer.Schema

  schema "messages" do
    field :body, :string
    field :edited, :boolean

    belongs_to :room, ChatServer.Schema.Room
    belongs_to :user, ChatServer.Schema.User

    timestamps()
  end
end
