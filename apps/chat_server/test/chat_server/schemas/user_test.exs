defmodule ChatServer.Schema.UserTest do
  alias ChatServer.Schema.Group
  alias ChatServer.Schema.Room
  alias ChatServer.Schema.User
  alias ChatServer.Repo

  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "groups association" do
    setup do
      {:ok, group} = Group.create(%{name: "admin"})
      {:ok, user} = User.create(%{name: "Test User"})
      {:ok, group: group, user: user}
    end

    test "is successfully updated when groups are included in params", %{group: group, user: user} do
      params = %{groups: [group]}
      {:ok, user} = User.update_groups(user, params)

      user = User.preload(user, [:groups])
      assert user.groups == [group]

      params = %{groups: user.groups}
      {:ok, user} = User.update_groups(user, params)

      user = User.preload(user, [:groups])
      assert user.groups == [group]
    end

    test "it replaces existing association", %{group: group, user: user} do
      # Add intial group
      params = %{groups: [group]}
      {:ok, user} = User.update_groups(user, params)

      user = User.preload(user, [:groups])
      assert user.groups == [group]

      # Replace group
      {:ok, new_group} = Group.create(%{name: "New Group"})

      params = %{groups: [new_group]}
      {:ok, user} = User.update_groups(user, params)

      user = User.preload(user, [:groups])
      assert user.groups == [new_group]
    end

    test "updating attributes does not replace existing association", %{group: group, user: user} do
      # Add intial group
      params = %{groups: [group]}
      {:ok, user} = User.update_groups(user, params)

      user = User.preload(user, [:groups])
      assert user.groups == [group]

      # Update other attributes
      params = %{name: "New Name"}
      {:ok, user} = User.update(user, params)

      user = User.preload(user, [:groups])
      assert user.name == "New Name"
      assert user.groups == [group]
    end

    test "all are deleted if params key is omitted", %{user: user} do
      params = %{}

      {:ok, user} = User.update_groups(user, params)

      user = User.preload(user, [:groups])
      assert user.groups == []
    end

    test "all are deleted if passed an empty list", %{user: user} do
      params = %{groups: []}

      {:ok, user} = User.update_groups(user, params)

      user = User.preload(user, [:groups])
      assert user.groups == []
    end
  end

  describe "rooms association" do
    setup do
      {:ok, room} = Room.create(%{name: "Test Room"})
      {:ok, user} = User.create(%{name: "Test User"})
      {:ok, room: room, user: user}
    end

    test "is successfully updated when rooms are included in params", %{room: room, user: user} do
      params = %{rooms: [room]}
      {:ok, user} = User.update_rooms(user, params)

      user = User.preload(user, [:rooms])
      assert user.rooms == [room]

      params = %{rooms: user.rooms}
      {:ok, user} = User.update_rooms(user, params)

      user = User.preload(user, [:rooms])
      assert user.rooms == [room]
    end

    test "it replaces existing association", %{room: room, user: user} do
      # Add intial room
      params = %{rooms: [room]}
      {:ok, user} = User.update_rooms(user, params)

      user = User.preload(user, [:rooms])
      assert user.rooms == [room]

      # Replace room
      {:ok, new_room} = Room.create(%{name: "New room"})

      params = %{rooms: [new_room]}
      {:ok, user} = User.update_rooms(user, params)

      user = User.preload(user, [:rooms])
      assert user.rooms == [new_room]
    end

    test "updating attributes does not replace existing association", %{room: room, user: user} do
      # Add intial room
      params = %{rooms: [room]}
      {:ok, user} = User.update_rooms(user, params)

      user = User.preload(user, [:rooms])
      assert user.rooms == [room]

      # Update other attributes
      params = %{name: "New Name"}
      {:ok, user} = User.update(user, params)

      user = User.preload(user, [:rooms])
      assert user.name == "New Name"
      assert user.rooms == [room]
    end

    test "all are deleted if params key is omitted", %{user: user} do
      params = %{}

      {:ok, user} = User.update_rooms(user, params)

      user = User.preload(user, [:rooms])
      assert user.rooms == []
    end

    test "all are deleted if passed an empty list", %{user: user} do
      params = %{rooms: []}

      {:ok, user} = User.update_rooms(user, params)

      user = User.preload(user, [:rooms])
      assert user.rooms == []
    end
  end

  describe "different associations" do
    setup do
      {:ok, group} = Group.create(%{name: "admin"})
      {:ok, room} = Room.create(%{name: "Test Room"})
      {:ok, user} = User.create(%{name: "Test User"})
      {:ok, group: group, room: room, user: user}
    end

    test "updating one association does not remove the other", %{room: room, group: group, user: user} do
      # Create group association
      params = %{groups: [group]}
      {:ok, user} = User.update_groups(user, params)

      user = User.preload(user, [:groups])
      assert user.groups == [group]

      # Create room association
      params = %{rooms: [room]}
      {:ok, user} = User.update_rooms(user, params)

      user = User.preload(user, [:rooms])
      assert user.rooms == [room]

      # Confirm both associations still exist
      user = User.preload(user, [:groups, :rooms])
      assert user.groups == [group]
      assert user.rooms == [room]
    end
  end
end
