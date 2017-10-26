defmodule ChatWebsocket.UsersChannel do
  use Phoenix.Channel

  import ChatWebsocket.ChannelHelpers

  alias ChatServer.ListSubscriptions
  alias ChatServer.ListUsers
  alias ChatServer.TrackUsers
  alias Phoenix.Socket.Broadcast

  def join("users", _, socket) do
    send self(), :after_join

    ChatPubSub.subscribe(user_topic(socket))

    {:ok, socket}
  end

  # Callbacks

  def handle_info(:after_join, socket) do
    %{user: user} = socket.assigns

    TrackUsers.track(self(), user)

    push socket, "users", %{ users: ListUsers.call(user) }
    push socket, "users:connected:state", TrackUsers.list
    push socket, "user:current", user
    push socket, "user:current:subscriptions", %{
      subscriptions: ListSubscriptions.call(user)
    }

    {:noreply, socket}
  end

  # Additional Topics

  @doc """
  By default, a channel is subscribed to the topic matching its name. For
  example, `users` channel will automatically receive any events broadcasted to
  the `users` topic.

  A channel can be subscribed to additional topics using `ChatPubSub.subscribe`
  inside the `join` function. When a message is broadcasted to one of these
  topics it is processed in a `handle_info` function.

  Just like `handle_out` for the default topic, these `handle_info` functions
  can be used to filter data before pushing it over the channel.
  """
  def handle_info(%Broadcast{event: event, payload: payload}, socket) do
    push socket, event, payload

    {:noreply, socket}
  end

  # Filters

  intercept ["presence_diff"]

  def handle_out("presence_diff", payload, socket) do
    push socket, "users:connected:diff", payload

    {:noreply, socket}
  end
  def handle_out(event, payload, socket) do
    push socket, event, payload

    {:noreply, socket}
  end
end
