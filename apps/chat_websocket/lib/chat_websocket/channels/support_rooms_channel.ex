defmodule ChatWebsocket.SupportRoomsChannel do
  use Phoenix.Channel

  alias ChatServer.TrackSupportRooms

  def join("support_rooms", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    push socket, "rooms:support:state", TrackSupportRooms.list

    {:noreply, socket}
  end

  # Filters

  intercept ["presence_diff"]

  def handle_out("presence_diff", msg, socket) do
    push socket, "rooms:support:diff", msg

    {:noreply, socket}
  end
  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end
end
