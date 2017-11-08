defmodule ChatServer.UpdateSubscription do
  alias ChatServer.BroadcastEvent
  alias ChatServer.GetSubscription
  alias ChatServer.Repo
  alias ChatServer.Schema

  @allowed_params ["state"]

  def call(%Schema.User{} = user, %Schema.Room{} = room, params) do
    case GetSubscription.call(user, room) do
      {:ok, subscription} -> call(user, subscription, params)
      {:error, message} -> {:error, message}
    end
  end
  def call(user, %Schema.Subscription{} = subscription, params) do
    with true <- owner?(user, subscription),
         {:ok, subscription} <- update_record(subscription, params),
         :ok <- broadcast_event(subscription) do
      {:ok, Repo.preload(subscription, [:room, :user])}
    else
      _ -> {:error, "Error updating subscription"}
    end
  end

  defp owner?(user, subscription), do: user.id == subscription.user_id

  defp update_record(subscription, params) do
    Schema.Subscription.update(subscription, filter_params(params))
  end

  defp filter_params(params) do
    params
    |> Map.take(@allowed_params)
  end

  defp broadcast_event(subscription) do
    BroadcastEvent.call("subscription:updated", subscription)
  end
end
