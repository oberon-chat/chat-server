defmodule ChatServerWeb.RoomChannel do
  use Phoenix.Channel

  alias ChatServerWeb.Presence
  alias ChatServerWeb.Room

  def join("room:" <> room, _, socket) do
    room_pid = find_or_start_room_server(room)
    socket = socket
             |> assign(:room, room)
             |> assign(:room_pid, room_pid)

    send self(), :after_join

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    push socket, "message_state", Room.get_messages(socket)

    %{
      room: room,
      room_pid: room_pid,
      user: user
    } = socket.assigns

    Presence.track(socket, user, %{
      node_name: node_name(),
      online_at: :os.system_time(:milli_seconds)
    })

    Presence.track(room_pid, "rooms", room, %{
      name: room
    })

    Presence.track(room_pid, "room_pids", room, %{
      name: room,
      pid: room_pid
    })

    {:noreply, socket}
  end

  def handle_in("message:new", message, socket) do
    msg = %{
      user: socket.assigns.user,
      body: message,
      timestamp: :os.system_time(:milli_seconds)
    }

    Room.put_message(socket, msg)
    broadcast! socket, "message:new", msg

    {:noreply, socket}
  end

  def terminate(_message, socket) do
    userCount = Presence.list(socket) |> Map.keys |> length

    if userCount <= 1 do
      Room.stop(socket.assigns.room_pid)
    end
  end

  defp find_or_start_room_server(room) do
    case Presence.list("room_pids")[room] do
      nil ->
        {:ok, pid} = Room.start(room)
        pid
      %{metas: [%{pid: pid}]} ->
        pid
    end
  end

  defp node_name do
    node()
    |> Atom.to_string()
    |> String.split("@")
    |> List.first()
  end
end
