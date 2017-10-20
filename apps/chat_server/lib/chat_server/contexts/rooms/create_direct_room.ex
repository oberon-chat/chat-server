defmodule ChatServer.CreateDirectRoom do
  require Logger

  alias ChatServer.Schema

  def call(_user, params \\ %{}) do
    Logger.info "Creating room " <> inspect(params)

    # TODO verify user is allowed to create direct room
    # TODO verify direct room does not already exist

    # Schema.Room |> join(:left, [r], s in assoc(r, :subscriptions)) |> where(name: "6fc009db-acc2-4ba3-b4bc-2461fba7e2b4") |> Repo.all
    # (from r in Schema.Room, left_join: s in assoc(r, :subscriptions), where: s.updated_at == ^~N[2017-10-20 22:23:46.334945]) |> Repo.all

    with {:ok, other_user} <- get_other_user(params),
         {:ok, record} <- create_record(params) do
      {:ok, record}
    else
      _ -> {:error, "Error creating room"}
    end
  end

  defp get_other_user(params) do
    id = Map.get(params, "user_id")

    case Schema.User.get(id) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end

  defp create_record(params) do
    create_params
    |> Schema.Room.create
  end

  defp create_params(params) do
    uuid = Ecto.UUID.generate

    %{
      id: uuid,
      name: uuid,
      slug: uuid,
      type: "direct"
    }
  end
end
