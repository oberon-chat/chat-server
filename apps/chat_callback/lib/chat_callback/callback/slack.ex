defmodule ChatCallback.Callback.Slack do
  use ChatCallback.Callback

  def handle(message, state) do
    IO.puts "Slack received:"
    IO.inspect message

    {:noreply, state}
  end
end
