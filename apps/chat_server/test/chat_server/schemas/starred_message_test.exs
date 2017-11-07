defmodule ChatServer.Schema.StarredMessageTest do
  alias ChatServer.Schema.StarredMessage
  alias ChatServer.Schema.User
  alias ChatServer.Schema.Message
  alias ChatServer.Schema.Room
  alias ChatServer.Repo

  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "changeset" do
    setup do
      {:ok, user} = User.create(%{name: "Test User"})
      {:ok, room} = Room.create(%{name: "Water Cooler"})
      {:ok, message} = Message.create(%{body: "Test Message", room: room, user: user})
      {:ok, message: message, user: user}
    end

    test "Is valid when associated user and message are valid", %{user: user, message: message} do
      params = %{user_id: user.id, message_id: message.id}
      changeset = StarredMessage.changeset(%StarredMessage{}, params)
      assert changeset.valid?
    end
  end
end
