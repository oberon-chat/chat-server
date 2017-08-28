defmodule ChatServerWeb.RoomsChannel do
  use Phoenix.Channel

  alias ChatServerWeb.Presence

  def join("rooms", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list("rooms")

    {:noreply, socket}
  end
end
