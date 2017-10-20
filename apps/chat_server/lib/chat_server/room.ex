defmodule ChatServer.Room do
  use GenServer

  alias ChatServer.RoomSupervisor
  alias ChatServer.TrackRooms
  alias ChatServer.Schema

  defmodule State do
    defstruct [:room, messages: []]
  end

  def start(room) do
    Supervisor.start_child(RoomSupervisor, [room])
  end

  def start_link(room, opts \\ []) do
    GenServer.start_link(__MODULE__, room, opts)
  end

  def stop(room_pid) do
    name = get_name(room_pid)

    with :ok <- Supervisor.terminate_child(RoomSupervisor, room_pid) do
      ChatPubSub.broadcast! "rooms", "room:deleted", %{room: name}
    end
  end

  def get_name(%Phoenix.Socket{} = socket) do
    GenServer.call(get_pid(socket), {:get_name})
  end
  def get_name(pid) do
    GenServer.call(pid, {:get_name})
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

  def init(room) do
    {:ok, %State{room: room, messages: Schema.Room.get_messages(room)}}
  end

  def handle_call({:get_name}, _from, %{room: room} = state) do
    {:reply, %{name: room.name}, state}
  end

  def handle_call({:get_message, id}, _from, %{messages: messages} = state) do
    {:reply, %{message: find_message(messages, id)}, state}
  end

  def handle_call(:get_messages, _from, %{messages: messages} = state) do
    {:reply, %{messages: messages}, state}
  end

  def handle_call({:create_message, message}, _from, %{messages: messages} = state) do
    {:reply, {:ok, message}, %{state | messages: [message | messages]}}
  end

  def handle_call({:update_message, message}, _from, %{messages: messages} = state) do
    id = Map.get(message, :id)
    updated_messages = replace_message(messages, message, id)

    {:reply, {:ok, message}, %{state | messages: updated_messages}}
  end

  def handle_call({:delete_message, message}, _from, %{messages: messages} = state) do
    id = Map.get(message, "id")

    {:reply, {:ok, message}, %{state | messages: remove_message(messages, id)}}
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
end
