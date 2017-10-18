defmodule ChatWebsocket.UsersChannel do
  use Phoenix.Channel

  alias ChatServer.TrackUsers

  def join("users", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    TrackUsers.track(self(), socket.assigns.user)

    push socket, "users:state", TrackUsers.list
    push socket, "users:current", socket.assigns.user

    {:noreply, socket}
  end

  # Filters

  intercept ["presence_diff"]

  def handle_out("presence_diff", msg, socket) do
    push socket, "users:diff", msg

    {:noreply, socket}
  end
  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end
end
