defmodule ChatOAuth2.Provider.GitHub do
  require Logger

  def fetch(code, redirect_uri),
    do: fetch_access_token(code, redirect_uri)

  defp fetch_access_token(code, redirect_uri) do
    try do
      client = OAuth2.Provider.GitHub.get_token!([code: code], [redirect_uri: redirect_uri])
      token = client.token
      Logger.debug "GitHub client: " <> inspect(client)

      case token.access_token do
        nil -> {:error, "Error fetching github token: " <> token.other_params["error_description"]}
        _ -> fetch_user_data(client)
      end
    rescue
      error in ArgumentError -> Logger.error inspect(error)
        {:error, "Error fetching github token"}
    end
  end

  defp fetch_user_data(client) do
    case OAuth2.Provider.GitHub.get_user(client) do
      {:error, response} -> {:error, response}
      {:ok, user_data} ->
        Logger.debug "GitHub user data: " <> inspect(user_data)
        {:ok, create_user(client, user_data)}
    end
  end

  defp create_user(client, data) do
    %{
      provider: %{
        type: "github",
        provider_id: Integer.to_string(data["id"]),
        client_id: client.client_id,
        access_token: client.token.access_token,
        expires_at: client.token.expires_at,
        refresh_token: client.token.refresh_token
      },
      user: %{
        email: data["email"],
        name: data["name"]
      }
    }
  end
end
