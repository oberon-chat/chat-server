defmodule ChatServer.Schema.RoomTest do
  alias ChatServer.Schema.Room
  alias ChatServer.Repo

  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "changeset" do
    test "valid lowercase name" do
      params = %{name: "hello"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.valid? == true
    end

    test "it receives a default status from the schema definition" do
      params = %{name: "hello"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.data.status == "active"
    end
  end

  describe "changeset - transformations" do
    test "name gets downcased" do
      params = %{name: "HELLO"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.name == "hello"
    end

    test "status gets downcased" do
      params = %{status: "ACTive"}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.changes.status == "active"
    end
  end

  describe "changset - validations" do
    test "name is required" do
      params = %{}
      changeset = Room.changeset(%Room{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [name: {"can't be blank", [validation: :required]}]
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
