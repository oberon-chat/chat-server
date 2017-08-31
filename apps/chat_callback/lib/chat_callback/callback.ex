defmodule ChatCallback.Callback do
  use GenServer

  alias ChatCallback.CallbackSupervisor

  defstruct messages: []

  def start(name) do
    Supervisor.start_child(CallbackSupervisor, [name])
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def stop(pid) do
    Supervisor.terminate_child(CallbackSupervisor, pid)
  end

  def init(_name) do
    send self(), :init_subscribe

    {:ok, %ChatCallback.Callback{}}
  end

  def handle_info(:init_subscribe, state) do
    ChatPubSub.subscribe "rooms"

    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end
end
