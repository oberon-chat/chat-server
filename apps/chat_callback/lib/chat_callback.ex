defmodule ChatCallback do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(ChatCallback.Repo, []),
      supervisor(ChatCallback.CallbackSupervisor, []),
      worker(ChatCallback.CallbackInitializer, [], restart: :transient)
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
