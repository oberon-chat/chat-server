defmodule OpenSubscriptions do
  @moduledoc """
  Updates room user subscriptions to open state. Ensures any subscribed users
  see the newest messages, even if the user has previously closed the room in the
  client.
  """

  require Logger

  alias ChatServer.Repo
  alias ChatServer.Schema

  def call(%Schema.Room{type: "direct"} = room) do
    case open_subscriptions(room) do
      true -> :ok
      false -> :error
    end
  end
  def call(_), do: :ok

  defp open_subscriptions(room) do
    Repo.preload(room, [:subscriptions]).subscriptions
    |> Enum.map(&open_subscription/1)
    |> Enum.all?
  end

  defp open_subscription(%Schema.Subscription{state: "closed"} = subscription) do
    case update_record(subscription) do
      {:ok, _} -> :ok
      error ->
        Logger.debug "Error creating message " <> inspect(error)
        {:error, "Error opening subscription"}
    end
  end
  defp open_subscription(_), do: :ok

  defp update_record(subscription) do
    subscription
    |> Schema.Subscription.update_changeset(%{state: "open"})
    |> Repo.update
  end
end
