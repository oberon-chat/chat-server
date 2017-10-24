defmodule ChatWebsocket.ChannelHelpers do
  alias ChatServer.Schema.User
  alias Phoenix.Socket

  def reply(type, value, socket) when is_bitstring(value), do: reply(type, %{response: value}, socket)
  def reply(type, value, socket), do: {:reply, {type, value}, socket}

  def user_topic(%Socket{} = socket), do: user_topic(socket.assigns.user)
  def user_topic(%User{} = user), do: user_topic(user.id)
  def user_topic(id) when is_bitstring(id), do: "user:#{id}"

  def broadcast_user_event!(user, event, payload),
    do: ChatPubSub.broadcast!(user_topic(user), event, payload)
end
