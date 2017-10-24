defmodule OpenSubscriptions do
  @moduledoc """
  Updates room user subscriptions to open state. Ensures any subscribed users
  see the newest messages, even if the user has previously closed the room in the
  client.

  Returns a list of subscriptions that were updated. Returns an empty list if
  no records were updated.
  """

  require Logger

  alias ChatServer.Repo
  alias ChatServer.Schema

  def call(%Schema.Room{type: "direct"} = room) do
    {:ok, open_subscriptions(room)}
  end
  def call(_), do: []

  def open_subscriptions(room) do
    Repo.preload(room, [:subscriptions]).subscriptions
      |> Enum.map(&open_subscription/1)
      |> Enum.reject(&is_nil/1)
  end

  defp open_subscription(%Schema.Subscription{state: "closed"} = subscription) do
    case update_record(subscription) do
      {:ok, record} ->
        record
        |> Repo.preload([:room, :user])
      error ->
        Logger.debug "Error opening subscription " <> inspect(error)
        nil
    end
  end
  defp open_subscription(_), do: nil

  defp update_record(subscription) do
    subscription
    |> Schema.Subscription.update(%{state: "open"})
    |> Repo.update
  end
end
