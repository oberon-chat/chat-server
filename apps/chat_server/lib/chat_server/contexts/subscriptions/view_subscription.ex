defmodule ChatServer.ViewSubscription do
  alias ChatServer.GetSubscription
  alias ChatServer.Repo
  alias ChatServer.Schema

  def call(%Schema.User{} = user, %Schema.Room{} = room) do
    case GetSubscription.call(user, room) do
      {:ok, subscription} -> call(user, subscription)
      {:error, message} -> {:error, message}
    end
  end
  def call(user, %Schema.Subscription{} = subscription) do
    with true <- owner?(user, subscription),
         {:ok, subscription} <- update_record(subscription) do
      {:ok, Repo.preload(subscription, [:room, :user])}
    else
      _ -> {:error, "Error updating subscription"}
    end
  end

  defp owner?(user, subscription), do: user.id == subscription.user_id

  defp update_record(%{viewed_at: nil} = subscription) do
    Schema.Subscription.update(subscription, %{viewed_at: DateTime.utc_now})
  end
  defp update_record(subscription) do
    case DateTime.compare(subscription.viewed_at, DateTime.utc_now) do
      :lt -> Schema.Subscription.update(subscription, %{viewed_at: DateTime.utc_now})
      _ -> {:ok, subscription}
    end
  end
end
