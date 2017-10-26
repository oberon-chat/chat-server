defmodule ChatServer.RoomSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: (opts[:slug] || __MODULE__))
  end

  def init(:ok) do
    supervise([
      worker(ChatServer.Room, [], restart: :transient)
    ], strategy: :simple_one_for_one)
  end
end
