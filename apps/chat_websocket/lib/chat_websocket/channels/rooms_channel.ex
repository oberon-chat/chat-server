defmodule ChatWebsocket.RoomsChannel do
  use Phoenix.Channel

  import ChatWebsocket.ChannelHelpers

  alias ChatServer.CreateRoom
  alias ChatServer.CreateDirectRoom
  alias ChatServer.CreateSubscription
  alias ChatServer.ListPublicRooms
  alias ChatServer.Room

  def join("rooms", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    %{user: user} = socket.assigns

    push socket, "rooms:public", %{rooms: ListPublicRooms.call(user)}

    {:noreply, socket}
  end

  def handle_in("rooms:create", %{"type" => "direct"} = params, socket) do
    with {:ok, result} <- CreateDirectRoom.call(socket.assigns.user, params),
         {:ok, _} <- Room.start(result.record),
         :ok <- broadcast_user_event!(result.primary_user, "user:current:subscription:created", result.primary_subscription),
         :ok <- broadcast_user_event!(result.secondary_user, "user:current:subscription:created", result.secondary_subscription) do
      reply(:ok, %{room: result.record}, socket)
    else
      _ -> reply(:error, "Error creating room", socket)
    end
  end
  def handle_in("rooms:create", params, socket) do
    %{user: user} = socket.assigns

    with {:ok, record} <- CreateRoom.call(user, params),
         {:ok, _} <- Room.start(record),
         {:ok, subscription} <- CreateSubscription.call(user, record),
         :ok <- maybe_broadcast_room_creation!(socket, record),
         :ok <- broadcast_user_event!(user, "user:current:subscription:created", subscription) do
      reply(:ok, %{room: record}, socket)
    else
      _ -> reply(:error, "Error creating room", socket)
    end
  end

  defp maybe_broadcast_room_creation!(socket, record) do
    case record.type do
      "public" -> broadcast! socket, "rooms:public:created", record
      _ -> :ok
    end
  end

  # Filters

  def handle_out(event, payload, socket) do
    push socket, event, payload

    {:noreply, socket}
  end
end
