defmodule ChatServer.Schema.StarredMessageTest do
  alias ChatServer.Schema.StarredMessage
  alias ChatServer.Repo

  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "changeset" do
    @tag :pending
    test "message must exist" do

    end

    @tag :pending
    test "user must exist" do

    end

    @tag :pending
    test "a starred message is created" do

    end

    @tag :pending
    test "a starred message is deleted" do

    end
  end
end
