defmodule ChatServer.Schema.RoomTest do
  alias ChatServer.Schema.Room
  alias ChatServer.Repo

  import ChatServer.Factory

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

    test "it receives a default state and type from the schema definition" do
      params = %{name: "Hello"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.data.state == "active"
      assert changeset.data.type == "public"
    end
  end

  describe "changeset - transformations" do
    test "name keeps case" do
      params = %{name: "HELLO"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.name == "HELLO"
    end

    test "state gets downcased" do
      params = %{state: "ACTive"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.state == "active"
    end

    test "type gets downcased" do
      params = %{type: "PERSIstent"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.type == "persistent"
    end

    test "creates a slug" do
      params = %{name: "Hello World"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.slug == "hello-world"
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

    test "state must be in enum options" do
      params = %{name: "hello", state: "invalid-test"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [state: {"is invalid", [validation: :inclusion]}]
    end

    test "name + state must be unique" do
      assert {:ok, _} = %Room{}
        |> Room.changeset(%{name: "hello", state: "active"})
        |> Repo.insert

      assert {:error, _} = %Room{}
        |> Room.changeset(%{name: "hello", state: "active"})
        |> Repo.insert
    end
  end

  describe "queries - get_messages" do
    setup do
      room = insert(:room)
      message_one = insert(:message, %{body: "one", room: room})
      message_two = insert(:message, %{body: "two", room: room})
      message_three = insert(:message, %{body: "three", room: room})

      {:ok, room: room, message_one: message_one, message_two: message_two, message_three: message_three}
    end

    test "when passed a uuid it returns all values up to default limit", %{room: room} do
      result = Room.get_messages(room.id)
      assert length(result) == 3
    end

    test "when passed a room record it returns all values up to default limit", %{room: room} do
      result = Room.get_messages(room)
      assert length(result) == 3
    end

    test "when passed an optional inserted_after argument", %{room: room, message_one: message_one} do
      result = Room.get_messages(room, inserted_after: message_one.inserted_at)
      assert length(result) == 2
    end

    test "when passed an optional limit argument", %{room: room} do
      result = Room.get_messages(room, limit: 1)
      assert length(result) == 1
    end
  end
end
