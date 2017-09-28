defmodule ChatServer.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ChatServer.RoomSupervisor, [
        [name: ChatServer.RoomSupervisor]
      ])
    ]

    opts = [strategy: :one_for_one, name: ChatServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
