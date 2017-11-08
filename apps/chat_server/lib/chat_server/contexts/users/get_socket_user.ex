defmodule ChatServer.GetSocketUser do
  alias ChatServer.Auth
  alias ChatServer.Schema

  def call(%{"token" => token}) do
    case Auth.get_user(token) do
      {:ok, auth_user} -> get_or_create_by(:user, auth_user)
      _ -> :error
    end
  end
  def call(%{"type" => "guest"} = params) do
    get_or_create_by(:guest, params)
  end

  defp get_or_create_by(type, params) do
    type
    |> filtered_params(params)
    |> get_or_create_record
  end

  defp filtered_params(type, params) do
    Schema.User.filter_params(type, params)
  end

  defp get_or_create_record(params) do
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
        {:error, "Error creating user"}
    end
  end
end