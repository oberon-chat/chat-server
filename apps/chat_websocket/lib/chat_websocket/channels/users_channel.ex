defmodule ChatWebsocket.UsersChannel do
  use Phoenix.Channel

  alias ChatServer.ListSubscriptions
  alias ChatServer.ListUsers
  alias ChatServer.TrackUsers

  def join("users", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    %{user: user} = socket.assigns

    TrackUsers.track(self(), user)

    push socket, "users", %{ users: ListUsers.call(user) }
    push socket, "users:connected:state", TrackUsers.list
    push socket, "user:current", user
    push socket, "user:current:subscriptions", %{
      subscriptions: ListSubscriptions.call(user)
    }

    {:noreply, socket}
  end

  # Filters

  intercept ["presence_diff"]

  def handle_out("presence_diff", msg, socket) do
    push socket, "users:connected:diff", msg

    {:noreply, socket}
  end
  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end
end
