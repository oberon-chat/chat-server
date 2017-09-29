defmodule ChatServer do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ChatServer.Repo, []),
      supervisor(ChatServer.RoomSupervisor, [
        [name: ChatServer.RoomSupervisor]
      ]),
      supervisor(ChatServer.RoomInitializer, [
        [name: ChatServer.RoomInitializer]
      ])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
