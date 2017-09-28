defmodule ChatWebsocket.RoomChannel do
  use Phoenix.Channel

  alias ChatPubSub.Presence
  alias ChatServer.Room
  alias ChatServer.Schema.Message

  def join("room:" <> room, _, socket) do
    case find_room(room) do
      nil -> {:error, "Room #{room} does not exist"}
      pid -> 
        socket = socket
                 |> assign(:room, room)
                 |> assign(:room_pid, pid)

        send self(), :after_join

        {:ok, socket}
    end
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    push socket, "message_state", Room.get_messages(socket)

    Presence.track(socket, socket.assigns.user, %{
      node_name: node_name(),
      online_at: :os.system_time(:milli_seconds)
    })

    {:noreply, socket}
  end

  def handle_out(event, msg, socket) do
    push socket, event, msg

    {:noreply, socket}
  end

  def handle_in("message:create", message, socket) do
    with {:ok, message} <- Message.create(%{ body: message }) do
      %{
        room: room,
        room_pid: room_pid,
        user: user
      } = socket.assigns

      message = %{
        id: message.id,
        user: user,
        body: message.body,
        edited: message.edited,
        room: room,
        timestamp: message.inserted_at
      }

      Presence.update(room_pid, "rooms", room, fn (meta) ->
        Map.put(meta, :last_message, message)
      end)

      Room.create_message(socket, message)
      broadcast! socket, "message:created", message
    end

    {:noreply, socket}
  end

  def handle_in("message:update", message, socket) do
    with true <- Map.get(message, "user") == socket.assigns.user do
      %{message: updated} = Room.update_message(socket, message)

      broadcast! socket, "message:update", updated
    end

    {:noreply, socket}
  end

  def handle_in("message:delete", message, socket) do
    with true <- Map.get(message, "user") == socket.assigns.user,
         {:ok, _} <- Room.delete_message(socket, message) do
      broadcast! socket, "message:delete", message
    end

    {:noreply, socket}
  end

  def terminate(_message, socket) do
    userCount = Presence.list(socket) |> Map.keys |> length

    if userCount <= 1 do
      Room.stop(socket.assigns.room_pid)
    end
  end

  defp find_room(room, attempt \\ 1) do
    if attempt <= 4 do
      case Presence.list("room_pids")[room] do
        nil ->
          :timer.sleep(50)
          find_room(room, attempt + 1)
        %{metas: [%{pid: pid}]} ->
          pid
      end
    else
      nil
    end
  end

  defp node_name do
    node()
    |> Atom.to_string()
    |> String.split("@")
    |> List.first()
  end
end
