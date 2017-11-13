defmodule ChatWebsocket.RoomChannel do
  use Phoenix.Channel

  import ChatWebsocket.ChannelHelpers

  alias ChatServer.CreateMessage
  alias ChatServer.CreateSubscription
  alias ChatServer.DeleteMessage
  alias ChatServer.DeleteSubscription
  alias ChatServer.GetRoom
  alias ChatServer.GetSubscription
  alias ChatServer.ListSubscriptions
  alias ChatServer.Room
  alias ChatServer.UpdateMessage
  alias ChatServer.UpdateState
  alias ChatServer.UpdateSubscription
  alias ChatServer.ViewSubscription

  def join("room:" <> slug, _, socket) do
    with {:ok, room} <- GetRoom.call(slug: slug),
         {:ok, _} <- joinable?(socket.assigns.user, room) do
      join_room(socket, room)
    else
      _ -> {:error, "Error connecting to room channel"}
    end
  end

  defp joinable?(_user, %{type: "public"} = room), do: {:ok, room}
  defp joinable?(_user, %{type: "support"} = room), do: {:ok, room}
  defp joinable?(user, %{type: "direct"} = room), do: GetSubscription.call(user, room)
  defp joinable?(user, %{type: "private"} = room), do: GetSubscription.call(user, room)

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

  def handle_in("message:create", params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, record} <- CreateMessage.call(user, room, params),
         {:ok, _} <- Room.create_message(socket, record),
         {:ok, subscriptions} <- OpenSubscriptions.call(room),
         :ok <- broadcast_user_subscriptions!(subscriptions),
         :ok <- broadcast!(socket, "message:created", record) do
      reply(:ok, %{message: record}, socket)
    else
      _ -> reply(:error, "Error creating message", socket)
    end
  end

  def handle_in("message:update", params, socket) do
    %{user: user} = socket.assigns

    with {:ok, record} <- UpdateMessage.call(user, params),
         {:ok, message} <- Room.update_message(socket, record),
         :ok <- broadcast!(socket, "message:updated", message) do
      reply(:ok, %{message: record}, socket)
    else
      _ -> reply(:error, "Error updating message", socket)
    end
  end

  def handle_in("message:delete", params, socket) do
    %{user: user} = socket.assigns

    with {:ok, _} <- DeleteMessage.call(user, params),
         {:ok, message} <- Room.delete_message(socket, params),
         :ok <- broadcast!(socket, "message:deleted", message) do
      reply(:ok, %{message: message}, socket)
    else
      _ -> reply(:error, "Error deleting message", socket)
    end
  end

  def handle_in("room:subscription:create", _params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, subscription} <- CreateSubscription.call(user, room),
         :ok <- broadcast_user_event!(user, "user:current:subscription:created", subscription),
         :ok <- broadcast!(socket, "room:subscription:created", subscription) do
      reply(:ok, %{subscription: subscription}, socket)
    else
      _ -> reply(:error, "Error creating subscription", socket)
    end
  end

  def handle_in("room:subscription:update", params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, subscription} <- UpdateSubscription.call(user, room, params),
         :ok <- broadcast_user_event!(user, "user:current:subscription:updated", subscription) do
      reply(:ok, %{subscription: subscription}, socket)
    else
      _ -> reply(:error, "Error updating subscription", socket)
    end
  end

  def handle_in("room:subscription:view", _params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, subscription} <- ViewSubscription.call(user, room),
         :ok <- broadcast_user_event!(user, "user:current:subscription:updated", subscription) do
      reply(:ok, %{subscription: subscription}, socket)
    else
      _ -> reply(:error, "Error updating subscription", socket)
    end
  end

  def handle_in("room:subscription:delete", _params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, subscription} <- GetSubscription.call(user, room),
         {:ok, _} <- DeleteSubscription.call(user, room),
         :ok <- broadcast_user_event!(user, "user:current:subscription:deleted", subscription),
         :ok <- broadcast!(socket, "room:subscription:deleted", subscription) do
      reply(:ok, %{subscription: subscription}, socket)
    else
      _ -> reply(:error, "Error deleting subscription", socket)
    end
  end

  def handle_in("room:archive", _params, socket) do
    %{room: room, user: user} = socket.assigns

    with {:ok, room_state} <- UpdateState.call(room.id, user, "archived"),
         :ok <- broadcast!(socket, "room:archived", room) do
      reply(:ok, %{room: room_state}, socket)
    else
      _ -> reply(:error, "Error archiving room", socket)
    end
  end

  defp broadcast_user_subscriptions!(subscriptions) do
    Enum.map(subscriptions, fn (subscription) ->
      broadcast_user_event!(subscription.user, "user:current:subscription:updated", subscription)
    end)

    :ok
  end

  # Filters

  def handle_out(event, payload, socket) do
    push socket, event, payload

    {:noreply, socket}
  end
end
