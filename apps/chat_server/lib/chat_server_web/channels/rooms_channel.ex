defmodule ChatServerWeb.RoomsChannel do
  use Phoenix.Channel

  alias ChatServerWeb.Presence

  def join("rooms", _, socket) do
    send self(), :after_join

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    rooms = Presence.list("room")
            |> filter_rooms

    push socket, "room_state", rooms

    {:noreply, socket}
  end

  defp filter_rooms(rooms) do
    rooms
    |> Enum.reduce(%{}, &omit_pid/2)
  end

  defp omit_pid({key, value}, acc) do
    filtered = Map.get(value, :metas)
               |> hd
               |> Map.drop([:pid])

    Map.put(acc, key, %{metas: [filtered]})
  end
end
