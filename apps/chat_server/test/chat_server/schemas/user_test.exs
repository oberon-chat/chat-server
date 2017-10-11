defmodule ChatServer.Schema.UserTest do
  alias ChatServer.Schema.Group
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
end
