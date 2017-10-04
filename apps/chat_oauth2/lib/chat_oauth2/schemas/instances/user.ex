defmodule ChatOAuth2.User.Instance do
  alias ChatOAuth2.Repo
  alias ChatOAuth2.User
  alias ChatOAuth2.UserProvider.Instance, as: UserProviderInstance

  def find_or_create_by_provider(user_params, provider_params) do
    case UserProviderInstance.find_user(provider_params) do
      nil -> create_by(user_params)
      user -> {:ok, user}
    end
  end

  defp create_by(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert
  end
end
