defmodule ChatCallback.Callback.Slack do
  use ChatCallback.Callback

  def handle(%{event: "presence_diff"} = message, state) do
    event = [text: "Room created", user: "Unknown"]

    ChatCallback.Client.Slack.notify(event, state.client_opts)

    {:noreply, state}
  end

  def handle(_message, state) do
    {:noreply, state}
  end
end
