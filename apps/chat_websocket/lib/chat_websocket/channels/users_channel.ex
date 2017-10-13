defmodule ChatWebsocket.UsersChannel do
  use Phoenix.Channel

  def join("users", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    push socket, "users:current", socket.assigns.user

    {:noreply, socket}
  end

  # Filters

  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end
end
