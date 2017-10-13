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

  def handle_info(:after_join, socket) do
    %{user: user} = socket.assigns

    push socket, "presence_state", TrackRooms.list
    push socket, "room:subscriptions", ListSubscriptions.call(user)

    {:noreply, socket}
  end

  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end

  def handle_in("rooms:create", %{"name" => name}, socket) do
    %{user: user} = socket.assigns

    with {:ok, record} <- CreateRoom.call(%{name: name}),
         {:ok, _} <- CreateSubscription.call(user, record) do
      StartRoom.call(record)
    end

    {:noreply, socket}
  end
end
