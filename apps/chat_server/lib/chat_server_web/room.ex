defmodule ChatServerWeb.Room do
  use GenServer

  alias ChatServerWeb.Presence

  defstruct messages: []

  def start(room) do
    Supervisor.start_child(ChatServerWeb.RoomSupervisor, [room])
  end

  def start_link(room) do
    GenServer.start_link(__MODULE__, room)
  end

  def get_messages(%Phoenix.Socket{} = socket) do
    GenServer.call(socket.assigns[:room_pid], :get)
  end
  def get_messages(pid) do
    GenServer.call(pid, :get)
  end

  def put_message(%Phoenix.Socket{} = socket, msg) do
    GenServer.cast(socket.assigns[:room_pid], {:put, msg})
  end
  def put_message(pid, msg) do
    GenServer.cast(pid, {:put, msg})
  end

  def init(room) do
    Presence.track(self(), "room", room, %{pid: self(), name: room})
    {:ok, %ChatServerWeb.Room{}}
  end

  def handle_call(:get, _from, %{messages: messages} = state) do
    {:reply, %{messages: messages}, state}
  end

  def handle_cast({:put, msg}, %{messages: messages} = state) do
    {:noreply, %{state | messages: [msg | messages]}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
