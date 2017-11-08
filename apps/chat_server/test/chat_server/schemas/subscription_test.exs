defmodule ChatServer.Schema.SubscriptionTest do
  alias ChatServer.Schema.Subscription
  alias ChatServer.Repo

  import ChatServer.Factory

  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "changeset" do
    test "it receives a default state from the schema definition" do
      params = %{}
      changeset = Subscription.changeset(%Subscription{}, params)

      assert changeset.data.state == "open"
    end

    test "state gets downcased" do
      params = %{state: "CLOSED"}
      changeset = Subscription.changeset(%Subscription{}, params)

      assert changeset.changes.state == "closed"
    end

    test "state must be in enum options" do
      params = %{state: "invalid-test"}
      changeset = Subscription.changeset(%Subscription{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [state: {"is invalid", [validation: :inclusion]}]
    end
  end

  describe "create" do
    setup do
      room = insert(:room) |> Repo.preload([:users])
      user = insert(:user) |> Repo.preload([:rooms])

      {:ok, room: room, user: user}
    end

    test "is successful when passed valid associations", %{room: room, user: user} do
      params = %{room: room, user: user}

      {:ok, subscription} = Subscription.create(params)
      subscription = Repo.preload(subscription, [:room, :user])

      assert subscription.room == room
      assert subscription.user == user
    end

    test "sets a default values", %{room: room, user: user} do
      params = %{room: room, user: user}

      {:ok, subscription} = Subscription.create(params)

      assert subscription.state == "open"
    end

    test "raises an exception when passed invalid assocations", %{user: user} do
      params = %{room: nil, user: user}

      assert_raise Postgrex.Error, fn () ->
        Subscription.create(params)
      end
    end
  end

  describe "update" do
    setup do
      room = insert(:room) |> Repo.preload([:users])
      user = insert(:user) |> Repo.preload([:rooms])
      {:ok, subscription} = Subscription.create(%{room: room, user: user})

      {:ok, room: room, subscription: subscription, user: user}
    end

    test "can update attributes", %{room: room, subscription: subscription, user: user} do
      params = %{state: "muted", viewed_at: DateTime.utc_now()}

      {:ok, subscription} = Subscription.update(subscription, params)
      subscription = Repo.preload(subscription, [:room, :user])

      assert subscription.room == room
      assert subscription.user == user

      assert subscription.state == params.state
      assert subscription.viewed_at == params.viewed_at
    end
  end
end
