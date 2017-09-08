defmodule ChatWebhook.Webhook.Http do
  use ChatWebhook.Webhook

  def handle(%{event: "presence_diff"}, state) do
    event = [type: "Room Created", text: "Room created", user: "Unknown"]

    ChatWebhook.HttpDriver.notify(event, state.client_options)

    {:noreply, state}
  end

  def handle(_message, state) do
    {:noreply, state}
  end
end
