defmodule ChatWebsocket.RoomsChannel do
  use Phoenix.Channel

  alias ChatServer.CreateRoom
  alias ChatServer.CreateDirectRoom
  alias ChatServer.CreateSubscription
  alias ChatServer.GetUser
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
    with {:ok, record, subscription} <- CreateDirectRoom.call(socket.assigns.user, params),
         {:ok, _} <- Room.start(record) do
      # TODO: Whenever message is created, set both subscriptions to open.
      # TODO: publish subscription to other user
      push socket, "user:subscription:created", subscription

      reply(:ok, %{room: record}, socket)
    else
      _ -> reply(:error, "Error creating room", socket)
    end
  end
  def handle_in("rooms:create", params, socket) do
    %{user: user} = socket.assigns

    with {:ok, record} <- CreateRoom.call(user, params),
         {:ok, _} <- Room.start(record),
         {:ok, subscription} <- CreateSubscription.call(user, record),
         :ok <- maybe_broadcast_room_creation(socket, record) do
      push socket, "user:subscription:created", subscription

      reply(:ok, %{room: record}, socket)
    else
      _ -> reply(:error, "Error creating room", socket)
    end
  end

  defp maybe_broadcast_room_creation(socket, record) do
    case record.type do
      "public" -> broadcast socket, "rooms:public:created", record
      _ -> :ok
    end
  end

  defp reply(type, value, socket) when is_bitstring(value), do: reply(type, %{response: value}, socket)
  defp reply(type, value, socket), do: {:reply, {type, value}, socket}

  # Filters

  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end
end
