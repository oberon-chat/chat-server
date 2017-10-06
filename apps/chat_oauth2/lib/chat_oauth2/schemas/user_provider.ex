defmodule ChatOAuth2.UserProvider do
  use ChatOAuth2.Schema

  schema "user_providers" do
    field :type, :string
    field :provider_id, :string
    field :client_id, :string
    field :access_token, :string
    field :expires_at, :integer
    field :refresh_token, :string
    belongs_to :user, ChatOAuth2.User
    timestamps()
  end

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :provider_id, :client_id, :access_token, :expires_at, :refresh_token, :user_id])
    |> validate_required([:type, :provider_id, :user_id])
  end

  # Queries

  def find_user(%{provider_id: provider_id, type: type}) do
    case Repo.get_by(UserProvider, provider_id: provider_id, type: type) do
      nil -> nil
      provider -> Repo.preload(provider, [:user]).user
    end
  end

  # Mutations

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
