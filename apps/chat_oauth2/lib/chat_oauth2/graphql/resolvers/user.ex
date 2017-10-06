defmodule ChatOAuth2.GraphQL.Resolver.User do
  require Logger

  alias ChatOAuth2.Repo
  alias ChatOAuth2.CurrentUser
  alias ChatOAuth2.LogIn.Facebook
  alias ChatOAuth2.LogIn.GitHub
  alias ChatOAuth2.User
  alias ChatOAuth2.UserProvider

  def introspect(_params, info) do
    Repo.get(User, CurrentUser.id(info))
  end

  def update(%{id: id, user: user_params}, info) do
    case id == CurrentUser.id(info) do
      false -> {:error, "Not authorized to update user account #{id}"}
      true -> Repo.get!(User, id)
              |> User.update_changeset(user_params)
              |> Repo.update
    end
  end

  def log_in_with_provider(params, _info) do
    with {:ok, data} <- get_provider_data(params),
         {:ok, user} <- User.find_or_create_by_provider(data[:user], data[:provider]),
         {:ok, _} <- UserProvider.create_or_update_by(user, data[:provider]),
         {:ok, jwt, %{"exp" => expires}} <- Guardian.encode_and_sign(user, :access) do
      Logger.debug "Session: " <> inspect(%{token: jwt, token_expiration: expires, user: user})
      {:ok, %{token: jwt, token_expiration: expires, user: user}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_provider_data(%{code: code, provider: provider, redirect_uri: redirect_uri}) do
    case provider do
      "facebook" -> Facebook.fetch(code, redirect_uri)
      "github" -> GitHub.fetch(code, redirect_uri)
      _ -> {:error, "Provider #{provider} not supported"}
    end
  end
end
