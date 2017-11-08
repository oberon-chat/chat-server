defmodule ChatServer.BroadcastEvent do
  @key "internal:events"

  def call(key, value) when is_bitstring(key) do
    ChatPubSub.broadcast("internal:events", key, value)
  end

  def key, do: @key
end
