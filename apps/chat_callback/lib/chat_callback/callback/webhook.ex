defmodule ChatCallback.Callback.Webhook do
  use ChatCallback.Callback

  def deliver(message, state) do
    IO.puts "message received:"
    IO.inspect message
    IO.puts "done"

    {:noreply, state}
  end

  # def handle_info(:init_subscribe, state) do
  #   ChatPubSub.subscribe "rooms"

  #   {:noreply, state}
  # end

  # def handle_info(_message, state) do
  #   {:noreply, state}
  # end
end
