defmodule ChatServer.GetDirectRoom do
  require Logger

  import Ecto.Query

  alias ChatServer.Repo
  alias ChatServer.Schema

  def call(%Schema.User{} = first_user, %Schema.User{} = second_user) do
    case get_record(first_user, second_user) do
      nil -> {:error, "Room not found"}
      record -> {:ok, record}
    end
  end 

  defp get_record(first_user, second_user) do
    first_user
    |> by_user_query(second_user)
    |> Repo.one
  end

  defp by_user_query(first_user, second_user) do
    from r in Schema.Room,
    left_join: s0 in assoc(r, :subscriptions),
    left_join: s1 in assoc(r, :subscriptions),
    where: s0.user_id == ^first_user.id,
    where: s1.user_id == ^second_user.id,
    where: r.type == "direct"
  end
end
