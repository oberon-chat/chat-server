defmodule ChatServer.Room do
  use GenServer

  alias ChatServer.RoomSupervisor

  defmodule State do
    defstruct [:name, messages: []]
  end

  def start(name) do
    Supervisor.start_child(RoomSupervisor, [name])
  end

  def start_link(name, opts \\ []) do
    GenServer.start_link(__MODULE__, name, opts)
  end

  def stop(room_pid) do
    name = get_name(room_pid)

    with :ok <- Supervisor.terminate_child(RoomSupervisor, room_pid) do
      ChatPubSub.broadcast! "rooms", "room:deleted", %{room: name}
    end
  end

  def get_name(%Phoenix.Socket{} = socket) do
    GenServer.call(socket.assigns[:room_pid], {:get_name})
  end
  def get_name(pid) do
    GenServer.call(pid, {:get_name})
  end

  def get_message(%Phoenix.Socket{} = socket, id) do
    GenServer.call(socket.assigns[:room_pid], {:get_message, id})
  end
  def get_message(pid, id) do
    GenServer.call(pid, {:get_message, id})
  end

  def get_messages(%Phoenix.Socket{} = socket) do
    GenServer.call(socket.assigns[:room_pid], :get_messages)
  end
  def get_messages(pid) do
    GenServer.call(pid, :get_messages)
  end

  def update_message(%Phoenix.Socket{} = socket, message) do
    GenServer.call(socket.assigns[:room_pid], {:update_message, message})
  end
  def update_message(pid, message) do
    GenServer.call(pid, {:update_message, message})
  end

  def delete_message(%Phoenix.Socket{} = socket, message) do
    GenServer.call(socket.assigns[:room_pid], {:delete_message, message})
  end
  def delete_message(pid, message) do
    GenServer.call(pid, {:delete_message, message})
  end

  def create_message(%Phoenix.Socket{} = socket, msg) do
    GenServer.cast(socket.assigns[:room_pid], {:create_message, msg})
  end
  def create_message(pid, msg) do
    GenServer.cast(pid, {:create_message, msg})
  end

  def init(name) do
    {:ok, %State{name: name}}
  end

  def handle_call({:get_name}, _from, %{name: name} = state) do
    {:reply, %{name: name}, state}
  end

  def handle_call({:get_message, id}, _from, %{messages: messages} = state) do
    {:reply, %{message: find_message(messages, id)}, state}
  end

  def handle_call(:get_messages, _from, %{messages: messages} = state) do
    {:reply, %{messages: messages}, state}
  end

  def handle_call({:update_message, message}, _from, %{messages: messages} = state) do
    id = Map.get(message, "id")
    body = Map.get(message, "body")
    current = find_message(messages, id)
    updated = %{ current | body: body, edited: true }
    updated_messages = replace_message(messages, updated, id)

    ChatPubSub.broadcast! "rooms", "message:updated", updated

    {:reply, %{message: updated}, %{state | messages: updated_messages}}
  end

  def handle_call({:delete_message, message}, _from, %{messages: messages} = state) do
    id = Map.get(message, "id")

    ChatPubSub.broadcast! "rooms", "message:deleted", message

    {:reply, {:ok, id}, %{state | messages: remove_message(messages, id)}}
  end

  def handle_cast({:create_message, message}, %{messages: messages} = state) do
    ChatPubSub.broadcast! "rooms", "message:created", message

    {:noreply, %{state | messages: [message | messages]}}
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
end
