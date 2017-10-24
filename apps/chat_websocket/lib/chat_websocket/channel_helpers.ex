defmodule ChatWebsocket.ChannelHelpers do
  alias ChatServer.Schema.User
  alias Phoenix.Socket

  def user_topic(%Socket{} = socket), do: user_topic(socket.assigns.user)
  def user_topic(%User{} = user), do: user_topic(user.id)
  def user_topic(id) when is_bitstring(id), do: "user:#{id}"
end
