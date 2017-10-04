defmodule ChatOAuth2.UserProvider.Instance do
  alias ChatOAuth2.Repo
  alias ChatOAuth2.UserProvider

  def find_user(%{provider_id: provider_id, type: type}) do
    case Repo.get_by(UserProvider, provider_id: provider_id, type: type) do
      nil -> nil
      provider -> Repo.preload(provider, [:user]).user
    end
  end

  def create_or_update_by(user, %{provider_id: provider_id, type: type} = params) do
    case Repo.get_by(UserProvider, provider_id: provider_id, type: type) do
      nil -> create_by(user, params)
      provider -> update_by(provider, params)
    end
  end

  defp create_by(user, params) do
    %UserProvider{}
    |> Map.put(:user_id, user.id)
    |> UserProvider.changeset(params)
    |> Repo.insert
  end

  defp update_by(provider, params) do
    provider
    |> UserProvider.changeset(params)
    |> Repo.update
  end
end
