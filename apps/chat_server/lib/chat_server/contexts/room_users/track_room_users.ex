defmodule ChatServer.TrackRoomUsers do
  alias ChatPubSub.Presence

  def track(socket, user) do
    Presence.track(socket, key(user), %{
      node_name: node_name(),
      online_at: :os.system_time(:milli_seconds)
    })
  end

  def list(socket), do: Presence.list(socket)

  def get(socket, user), do: Keyword.get(list(socket), key(user))

  defp key(user), do: user.name

  defp node_name do
    node()
    |> Atom.to_string()
    |> String.split("@")
    |> List.first()
  end
end
