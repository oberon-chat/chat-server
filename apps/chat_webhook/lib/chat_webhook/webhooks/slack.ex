defmodule ChatWebhook.Webhook.Slack do
  use ChatWebhook.Webhook

  def handle(%{event: "presence_diff"}, state) do
    event = [text: "Room created", user: "Unknown"]

    ChatWebhook.SlackDriver.notify(event, state.client_options)

    {:noreply, state}
  end

  def handle(_message, state) do
    {:noreply, state}
  end
end
