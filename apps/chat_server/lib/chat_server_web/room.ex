defmodule ChatServerWeb.Room do
  use GenServer

  alias ChatServerWeb.RoomSupervisor

  defstruct messages: []

  def start(room) do
    Supervisor.start_child(RoomSupervisor, [room])
  end

  def start_link(room) do
    GenServer.start_link(__MODULE__, room)
  end

  def stop(room_pid) do
    Supervisor.terminate_child(RoomSupervisor, room_pid)
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

  def put_message(%Phoenix.Socket{} = socket, msg) do
    GenServer.cast(socket.assigns[:room_pid], {:put_message, msg})
  end
  def put_message(pid, msg) do
    GenServer.cast(pid, {:put_message, msg})
  end

  def init(_room) do
    {:ok, %ChatServerWeb.Room{}}
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

    {:reply, %{message: updated}, %{state | messages: updated_messages}}
  end

  def handle_cast({:put_message, message}, %{messages: messages} = state) do
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
end
