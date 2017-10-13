defmodule ChatWebsocket.RoomsChannel do
  use Phoenix.Channel

  alias ChatServer.CreateRoom
  alias ChatServer.CreateSubscription
  alias ChatServer.ListSubscriptions
  alias ChatServer.StartRoom
  alias ChatServer.TrackRooms

  def join("rooms", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    %{user: user} = socket.assigns
    subscriptions = ListSubscriptions.call(user)

    push socket, "rooms:state", TrackRooms.list
    push socket, "room:subscriptions", %{subscriptions: subscriptions}

    {:noreply, socket}
  end

  def handle_in("rooms:create", %{"name" => name}, socket) do
    %{user: user} = socket.assigns

    with {:ok, record} <- CreateRoom.call(%{name: name}),
         {:ok, subscription} <- CreateSubscription.call(user, record),
         {:ok, pid} <- StartRoom.call(record) do
      push socket, "room:subscribed", subscription
    end

    {:noreply, socket}
  end

  # Filters

  intercept ["presence_diff"]

  def handle_out("presence_diff", msg, socket) do
    push socket, "rooms:diff", msg

    {:noreply, socket}
  end
  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end
end
