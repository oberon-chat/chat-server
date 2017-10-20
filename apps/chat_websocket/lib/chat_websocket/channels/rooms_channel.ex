defmodule ChatWebsocket.RoomsChannel do
  use Phoenix.Channel

  alias ChatServer.CreateRoom
  alias ChatServer.CreateSubscription
  alias ChatServer.ListPublicRooms
  alias ChatServer.Room

  def join("rooms", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    public_rooms = ListPublicRooms.call(socket.assigns.user)

    push socket, "rooms:public", %{rooms: public_rooms}

    {:noreply, socket}
  end

  def handle_in("rooms:create", params, socket) do
    %{user: user} = socket.assigns

    with {:ok, record} <- CreateRoom.call(params, user),
         :ok <- broadcast_room_creation(socket, record),
         {:ok, subscription} <- CreateSubscription.call(user, record),
         {:ok, _} <- Room.start(record) do
      push socket, "user:subscription:created", subscription

      reply(:ok, %{room: record}, socket)
    else
      _ -> reply(:error, "Error creating socket", socket)
    end
  end

  defp reply(type, value, socket), do: {:reply, {type, value}, socket}

  defp broadcast_room_creation(socket, record) do
    case record.type do
      "public" -> broadcast socket, "rooms:public:created", record
      _ -> :ok
    end
  end

  # Filters

  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end
end
