defmodule ChatWebhook.WebhookInitializer do
  use GenServer

  alias ChatWebhook.WebhookSupervisor
  alias ChatWebhook.Callback
  alias ChatWebhook.Repo

  defmodule State do
    defstruct started: []
  end

  def start_link do
    callbacks = Repo.all(Callback)

    GenServer.start_link(__MODULE__, callbacks)
  end

  def init(callbacks) do
    started = Enum.map(callbacks, &start_webhook/1)

    {:ok, %State{started: started}}
  end

  defp start_webhook(callback) do
    case WebhookSupervisor.start_webhook(callback) do
      {:ok, pid} -> pid
      _ -> nil
    end
  end
end
