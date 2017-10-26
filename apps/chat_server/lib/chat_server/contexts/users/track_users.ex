defmodule ChatServer.TrackUsers do
  @moduledoc """
  Tracks public-facing information about user connections using Presence.
  """

  require Logger

  alias ChatPubSub.Presence

  @presence_key "users"
  @presence_pid_key "internal:user_pids"

  # Queries

  def list, do: Presence.list(@presence_key)

  # Mutations

  def track(pid, user) do
    case Map.get(list(), key(user)) do
      nil ->
        Presence.track(pid, @presence_key, key(user), %{
          id: user.id,
          name: user.name
        })
        Presence.track(pid, @presence_pid_key, key(user), %{
          pid: pid
        })
      _data ->
        Logger.warn "User already tracked #{user.name} (#{user.id}) " <> inspect(pid)
        :error
    end
  end

  def update(user, values), do: update(get_user_pid(user), user, values)
  def update(pid, user, values) do
    Presence.update(pid, @presence_key, key(user), fn (meta) ->
      Map.merge(meta, values)
    end)
  end

  # Private Helpers

  defp key(user), do: user.id

  defp get_user_pid(user) do
    case Presence.list(@presence_pid_key)[key(user)] do
      %{metas: [%{pid: pid}]} ->
        pid
      %{metas: metas} ->
        Logger.warn "Multiple users tracked " <> inspect(metas)
        Map.get(hd(metas), :pid)
      _ ->
        nil
    end
  end
end
