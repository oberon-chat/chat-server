defmodule ChatWebhook.Webhook.Http do
  use ChatWebhook.Webhook

  def handle(_message, state) do
    {:noreply, state}
  end
end
