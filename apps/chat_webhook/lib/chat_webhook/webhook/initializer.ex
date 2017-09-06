defmodule ChatWebhook.WebhookInitializer do
  use GenServer

  alias ChatWebhook.WebhookSupervisor
  alias ChatWebhook.Record
  alias ChatWebhook.Repo

  defmodule State do
    defstruct started: []
  end

  def start_link do
    records = Repo.all(Record)

    GenServer.start_link(__MODULE__, records)
  end

  def init(records) do
    started = Enum.map(records, &start_webhook/1)

    {:ok, %State{started: started}}
  end

  defp start_webhook(record) do
    case WebhookSupervisor.start_webhook(record) do
      {:ok, pid} -> pid
      _ -> nil
    end
  end
end
