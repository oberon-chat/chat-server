defmodule ChatWebsocket.RoomChannel do
  use Phoenix.Channel

  import ChatWebsocket.ChannelHelpers

  alias ChatServer.Room
  alias ChatServer.CreateMessage
  alias ChatServer.CreateSubscription
  alias ChatServer.DeleteMessage
  alias ChatServer.DeleteSubscription
  alias ChatServer.GetRoom
  alias ChatServer.ListSubscriptions
  alias ChatServer.UpdateMessage
  alias ChatServer.UpdateSubscription

  def join("room:" <> slug, _, socket) do
    case GetRoom.call(slug: slug) do
      {:ok, room} -> join_room(socket, room)
      {:error, _} -> {:error, "Room #{slug} does not exist"}
    end
  end

  defp join_room(socket, room) do
    send self(), :after_join
    {:ok, assign(socket, :room, room)}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    push socket, "messages", Room.get_messages(socket)
    push socket, "room:subscriptions", %{
      subscriptions: ListSubscriptions.call(socket.assigns.room)
    }

    {:noreply, socket}
  end

  def handle_in("room:subscription:create", _params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, subscription} <- CreateSubscription.call(user, room) do
      ChatPubSub.broadcast! user_topic(socket), "user:current:subscription:created", subscription
      broadcast! socket, "room:subscription:created", subscription
    end

    {:noreply, socket}
  end

  def handle_in("room:subscription:update", params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, subscription} <- UpdateSubscription.call(user, room, params) do
      ChatPubSub.broadcast! user_topic(socket), "user:current:subscription:updated", subscription
      broadcast! socket, "room:subscription:updated", subscription
    end

    {:noreply, socket}
  end

  def handle_in("room:subscription:delete", _params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, subscription} <- DeleteSubscription.call(user, room) do
      broadcast! socket, "room:subscription:deleted", subscription
    end

    {:noreply, socket}
  end

  def handle_in("message:create", params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, record} <- CreateMessage.call(user, room, params),
         {:ok, _} <- Room.create_message(socket, record),
         {:ok, subscriptions} <- OpenSubscriptions.call(room),
         :ok <- broadcast_user_subscriptions!(subscriptions) do
      broadcast! socket, "message:created", record
    end

    {:noreply, socket}
  end

  def handle_in("message:update", params, socket) do
    %{user: user} = socket.assigns

    with {:ok, record} <- UpdateMessage.call(user, params),
         {:ok, message} <- Room.update_message(socket, record) do
      broadcast! socket, "message:updated", message
    end

    {:noreply, socket}
  end

  def handle_in("message:delete", params, socket) do
    %{user: user} = socket.assigns

    with {:ok, _} <- DeleteMessage.call(user, params),
         {:ok, message} <- Room.delete_message(socket, params) do
      broadcast! socket, "message:deleted", message
    end

    {:noreply, socket}
  end

  defp broadcast_user_subscriptions!(subscriptions) do
    Enum.map(subscriptions, fn (subscription) ->
      ChatPubSub.broadcast! user_topic(subscription.user), "user:current:subscription:updated", subscription
    end)

    :ok
  end

  # Filters

  def handle_out(event, payload, socket) do
    push socket, event, payload

    {:noreply, socket}
  end
end
