defmodule ChatServer.CreateSubscriptionTest do
  alias ChatServer.CreateSubscription
  alias ChatServer.Repo
  alias ChatServer.Schema

  import ChatServer.Factory

  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "call" do
    setup do
      room = insert(:room) |> Repo.preload([:users])
      user = insert(:user) |> Repo.preload([:rooms])

      {:ok, room: room, user: user}
    end

    test "with two schema records", %{room: room, user: user} do
      assert room.users == []
      assert user.rooms == []

      CreateSubscription.call(user, room)

      room = Repo.get(Schema.Room, room.id)
      user = Repo.get(Schema.User, user.id)

      assert Repo.preload(room, [:users]).users == [user]
      assert Repo.preload(user, [:rooms]).rooms == [room]
    end

    test "with user id", %{room: room, user: user} do
      assert room.users == []
      assert user.rooms == []

      CreateSubscription.call(user.id, room)

      room = Repo.get(Schema.Room, room.id)
      user = Repo.get(Schema.User, user.id)

      assert Repo.preload(room, [:users]).users == [user]
      assert Repo.preload(user, [:rooms]).rooms == [room]
    end

    test "with room id", %{room: room, user: user} do
      assert room.users == []
      assert user.rooms == []

      CreateSubscription.call(user, room.id)

      room = Repo.get(Schema.Room, room.id)
      user = Repo.get(Schema.User, user.id)

      assert Repo.preload(room, [:users]).users == [user]
      assert Repo.preload(user, [:rooms]).rooms == [room]
    end
  end
end
