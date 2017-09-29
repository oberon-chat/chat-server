defmodule ChatServer.Schema.RoomTest do
  alias ChatServer.Schema.Room
  alias ChatServer.Repo

  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "changeset" do
    test "valid name" do
      params = %{name: "Hello"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.valid? == true
    end

    test "it receives a default status and type from the schema definition" do
      params = %{name: "Hello"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.data.status == "active"
      assert changeset.data.type == "persistent"
    end
  end

  describe "changeset - transformations" do
    test "name keeps case" do
      params = %{name: "HELLO"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.name == "HELLO"
    end

    test "status gets downcased" do
      params = %{status: "ACTive"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.status == "active"
    end

    test "type gets downcased" do
      params = %{type: "PERSIstent"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.type == "persistent"
    end

    test "creates a slug" do
      params = %{name: "Hello World"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.slug == "helloworld"
    end

    test "slug is not changed on update" do
      {:ok, room} = %Room{}
        |> Room.changeset(%{name: "Hello"})
        |> Repo.insert

      assert room.name == "Hello"
      assert room.slug == "hello"

      {:ok, room} = room
        |> Room.changeset(%{name: "World"})
        |> Repo.update

      assert room.name == "World"
      assert room.slug == "hello"
    end
  end

  describe "changset - validations" do
    test "name is required" do
      params = %{}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [name: {"can't be blank", [validation: :required]}]
    end

    test "type must be in enum options" do
      params = %{name: "hello", type: "invalid-test"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [type: {"is invalid", [validation: :inclusion]}]
    end

    test "status must be in enum options" do
      params = %{name: "hello", status: "invalid-test"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [status: {"is invalid", [validation: :inclusion]}]
    end

    test "name + status must be unique" do
      assert {:ok, _} = %Room{}
        |> Room.changeset(%{name: "hello", status: "active"})
        |> Repo.insert

      assert {:error, _} = %Room{}
        |> Room.changeset(%{name: "hello", status: "active"})
        |> Repo.insert
    end
  end
end
