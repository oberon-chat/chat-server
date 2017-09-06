defmodule ChatWebhook do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(ChatWebhook.Repo, []),
      supervisor(ChatWebhook.WebhookSupervisor, []),
      worker(ChatWebhook.WebhookInitializer, [], restart: :transient)
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
