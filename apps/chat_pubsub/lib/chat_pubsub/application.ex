defmodule ChatPubSub.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Phoenix.PubSub.PG2, [ChatPubSub, []]),
      supervisor(ChatPubSub.Presence, [])
    ]

    opts = [strategy: :one_for_one]
    # opts = [strategy: :one_for_one, name: ChatPubSub.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
