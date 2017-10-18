defmodule ChatServer.DeleteSubscriptionTest do
  alias ChatServer.CreateSubscription
  alias ChatServer.DeleteSubscription
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

      CreateSubscription.call(user, room)

      room = Repo.get(Schema.Room, room.id)
      user = Repo.get(Schema.User, user.id)

      {:ok, room: room, user: user}
    end

    test "returns the record", %{room: room, user: user} do
      {:ok, %Schema.Subscription{}} = DeleteSubscription.call(user, room)
    end

    test "with two schema records", %{room: room, user: user} do
      assert Repo.preload(room, [:users]).users == [user]
      assert Repo.preload(user, [:rooms]).rooms == [room]

      DeleteSubscription.call(user, room)

      room = Repo.get(Schema.Room, room.id) |> Repo.preload([:users])
      user = Repo.get(Schema.User, user.id) |> Repo.preload([:rooms])

      assert room.users == []
      assert user.rooms == []
    end

    test "with user id", %{room: room, user: user} do
      assert Repo.preload(room, [:users]).users == [user]
      assert Repo.preload(user, [:rooms]).rooms == [room]

      DeleteSubscription.call(user.id, room)

      room = Repo.get(Schema.Room, room.id) |> Repo.preload([:users])
      user = Repo.get(Schema.User, user.id) |> Repo.preload([:rooms])

      assert room.users == []
      assert user.rooms == []
    end

    test "with room id", %{room: room, user: user} do
      assert Repo.preload(room, [:users]).users == [user]
      assert Repo.preload(user, [:rooms]).rooms == [room]

      DeleteSubscription.call(user, room.id)

      room = Repo.get(Schema.Room, room.id) |> Repo.preload([:users])
      user = Repo.get(Schema.User, user.id) |> Repo.preload([:rooms])

      assert room.users == []
      assert user.rooms == []
    end
  end
end
