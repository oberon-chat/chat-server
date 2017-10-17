defmodule ChatServer.Room do
  require Logger

  use GenServer

  alias ChatServer.RoomSupervisor
  alias ChatServer.Schema
  alias ChatServer.TrackRooms
  alias ChatServer.TrackSupportRooms

  defmodule State do
    defstruct [:room, :last_message, messages: []]
  end

  def start(room) do
    Supervisor.start_child(RoomSupervisor, [room])
  end

  def start_link(room, opts \\ []) do
    GenServer.start_link(__MODULE__, room, opts)
  end

  def stop(room_pid) do
    with :ok <- Supervisor.terminate_child(RoomSupervisor, room_pid) do
      ChatPubSub.broadcast! "rooms", "room:deleted", %{room: get_slug(room_pid)}
    end
  end

  def get_slug(%Phoenix.Socket{} = socket) do
    GenServer.call(get_pid(socket), {:get_slug})
  end
  def get_slug(pid) do
    GenServer.call(pid, {:get_slug})
  end

  def get_message(%Phoenix.Socket{} = socket, id) do
    GenServer.call(get_pid(socket), {:get_message, id})
  end
  def get_message(pid, id) do
    GenServer.call(pid, {:get_message, id})
  end

  def get_messages(%Phoenix.Socket{} = socket) do
    GenServer.call(get_pid(socket), :get_messages)
  end
  def get_messages(pid) do
    GenServer.call(pid, :get_messages)
  end

  def create_message(%Phoenix.Socket{} = socket, msg) do
    GenServer.call(get_pid(socket), {:create_message, msg})
  end
  def create_message(pid, msg) do
    GenServer.call(pid, {:create_message, msg})
  end

  def update_message(%Phoenix.Socket{} = socket, message) do
    GenServer.call(get_pid(socket), {:update_message, message})
  end
  def update_message(pid, message) do
    GenServer.call(pid, {:update_message, message})
  end

  def delete_message(%Phoenix.Socket{} = socket, message) do
    GenServer.call(get_pid(socket), {:delete_message, message})
  end
  def delete_message(pid, message) do
    GenServer.call(pid, {:delete_message, message})
  end

  # Callbacks

  def init(room) do
    Logger.info "Started room process #{room.slug} (#{room.id})"

    {:ok, _} = TrackRooms.track(self(), room)
    messages = Schema.Room.get_messages(room)

    TrackSupportRooms.track(self(), room)

    {:ok, %State{room: room, last_message: get_last(messages), messages: messages}}
  end

  def handle_call({:get_slug}, _from, %{room: room} = state) do
    {:reply, %{slug: room.slug}, state}
  end

  def handle_call({:get_message, id}, _from, %{messages: messages} = state) do
    {:reply, %{message: find_message(messages, id)}, state}
  end

  def handle_call(:get_messages, _from, %{messages: messages} = state) do
    {:reply, %{messages: messages}, state}
  end

  def handle_call({:create_message, message}, _from, %{messages: messages} = state) do
    {:reply, {:ok, message}, %{state | last_message: message, messages: [message | messages]}}
  end

  def handle_call({:update_message, message}, _from, %{messages: messages} = state) do
    id = Map.get(message, :id)
    updated_messages = replace_message(messages, message, id)

    {:reply, {:ok, message}, %{state | messages: updated_messages}}
  end

  def handle_call({:delete_message, message}, _from, %{messages: messages} = state) do
    remaining = remove_message(messages, Map.get(message, "id"))

    {:reply, {:ok, message}, %{state | last_message: get_last(remaining), messages: remaining}}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp find_message(messages, id) do
    find_message = fn (item) -> Map.get(item, :id) == id end
    Enum.find(messages, find_message)
  end

  defp replace_message(messages, message, id) do
    Enum.map messages, fn (item) ->
      case Map.get(item, :id) == id do
        true -> message
        _ -> item
      end
    end
  end

  defp remove_message(messages, id) do
    with message <- find_message(messages, id) do
      messages |> List.delete(message)
    end
  end

  defp get_pid(socket) do
    TrackRooms.get_pid(socket.assigns[:room])
  end

  defp get_last([]), do: nil
  defp get_last(messages), do: hd(messages)
end
