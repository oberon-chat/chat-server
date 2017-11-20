defmodule ChatServer.CreateSubscription do
  alias ChatServer.BroadcastEvent
  alias ChatServer.Repo
  alias ChatServer.Schema

  # TODO: confirm user is allowed to subscribe to rooms
  # TODO: confirm room allows new subscriptions

  def call(user, room_id, opts \\ [])
  def call(user, room_id, opts) when is_bitstring(room_id) do
    room = Repo.get(Schema.Room, room_id)
    call(user, room, opts)
  end
  def call(user_id, room, opts) when is_bitstring(user_id) do
    user = Repo.get(Schema.User, user_id)
    call(user, room, opts)
  end
  def call(%Schema.User{} = user, %Schema.Room{} = room, opts) do
    params = opts
      |> Enum.into(%{})
      |> Map.put(:room, room)
      |> Map.put(:user, user)
      |> Map.put(:viewed_at, DateTime.utc_now)

    with {:ok, subscription} <- Schema.Subscription.create(params),
         subscription <- Repo.preload(subscription, [:room, :user]),
         :ok <- broadcast_event(subscription) do
      {:ok, subscription}
    else
      _ -> {:eror, "Error creating subscription"}
    end
  end

  defp broadcast_event(subscription) do
    BroadcastEvent.call("subscription:created", subscription)
  end
end
