defmodule ChatCallback.Callback.Webhook do
  use ChatCallback.Callback

  def handle(_message, state) do
    {:noreply, state}
  end
end
