defmodule ChatCallback.Callback.Slack do
  use ChatCallback.Callback

  def handle(_message, state) do
    {:noreply, state}
  end
end
