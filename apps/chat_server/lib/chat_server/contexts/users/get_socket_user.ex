defmodule ChatServer.GetSocketUser do
  alias ChatServer.Schema

  def call(type, params) when is_atom(type) do
    type
    |> filtered_params(params)
    |> get_or_create_by
  end

  defp filtered_params(type, params) do
    Schema.User.filter_params(type, params)
  end

  defp get_or_create_by(params) do
    case Schema.User.get_by(params) do
      nil -> create_user(params)
      user -> {:ok, user}
    end
  end

  defp create_user(params) do
    case Schema.User.create(params) do
      {:ok, user} ->
        ChatPubSub.broadcast("users", "user:created", user)
        {:ok, user}
      _ ->
        {:error, "Error creating user."}
    end
  end
end
