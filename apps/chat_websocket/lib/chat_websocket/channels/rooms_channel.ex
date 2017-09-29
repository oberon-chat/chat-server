defmodule ChatWebsocket.RoomsChannel do
  use Phoenix.Channel

  alias ChatServer.CreateRoom
  alias ChatServer.StartRoom
  alias ChatServer.TrackRooms

  def join("rooms", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", TrackRooms.list

    {:noreply, socket}
  end

  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end

  def handle_in("rooms:create", name, socket) do
    case CreateRoom.call(%{name: name}) do
      {:ok, record} -> StartRoom.call(record)
      _ -> nil
    end

    {:noreply, socket}
  end
end
