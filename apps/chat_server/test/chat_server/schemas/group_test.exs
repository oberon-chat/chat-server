defmodule ChatServer.Schema.GroupTest do
  alias ChatServer.Schema.Group
  alias ChatServer.Repo

  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "changeset" do
    test "valid name" do
      params = %{name: "Admin Group"}
      changeset = Group.changeset(%Group{}, params)

      assert changeset.valid? == true
    end
  end

  describe "changeset - transformations" do
    test "creates a slug" do
      params = %{name: "Hello World"}
      changeset = Group.changeset(%Group{}, params)

      assert changeset.changes.slug == "hello-world"
    end

    test "slug is not changed on update" do
      {:ok, room} = %Group{}
        |> Group.changeset(%{name: "Hello"})
        |> Repo.insert

      assert room.name == "Hello"
      assert room.slug == "hello"

      {:ok, room} = room
        |> Group.changeset(%{name: "World"})
        |> Repo.update

      assert room.name == "World"
      assert room.slug == "hello"
    end
  end

  describe "changset - validations" do
    test "name is required" do
      params = %{}
      changeset = Group.changeset(%Group{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [name: {"can't be blank", [validation: :required]}]
    end

    test "slug must be unique" do
      assert {:ok, _} = %Group{}
        |> Group.changeset(%{name: "hello"})
        |> Repo.insert

      assert {:error, _} = %Group{}
        |> Group.changeset(%{name: "hello"})
        |> Repo.insert
    end
  end
end
