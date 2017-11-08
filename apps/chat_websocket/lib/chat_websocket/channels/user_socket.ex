defmodule ChatWebsocket.UserSocket do
  require Logger

  use Phoenix.Socket

  alias ChatServer.GetSocketUser

  ## Channels
  channel "room:*", ChatWebsocket.RoomChannel
  channel "rooms", ChatWebsocket.RoomsChannel
  channel "support_rooms", ChatWebsocket.SupportRoomsChannel
  channel "users", ChatWebsocket.UsersChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(params, socket) do
    case GetSocketUser.call(params) do
      {:ok, user} ->
        Logger.debug "Socket connection for user #{user.name} (#{user.id})"
        {:ok, assign(socket, :user, user)}
      {:created, user} ->
        Logger.debug "Socket connection for user #{user.name} (#{user.id})"
        ChatPubSub.broadcast! "users", "user:created", user
        {:ok, assign(socket, :user, user)}
      _ ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ChatWebsocket.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(%{socket: %{assigns: %{user: %{id: id, name: name}}}}), do: "user_socket:#{id}:#{name}"
  def id(_socket), do: nil
end
