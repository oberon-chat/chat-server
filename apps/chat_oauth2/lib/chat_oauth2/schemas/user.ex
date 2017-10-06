defmodule ChatOAuth2.User do
  use ChatOAuth2.Schema

  alias Ecto.Changeset
  alias ChatOAuth2.UserProvider

  schema "users" do
    field :name, :string
    field :first_name, :string
    field :last_name, :string
    field :locale, :string
    field :email, :string
    has_many :user_providers, UserProvider
    timestamps()
  end

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :first_name, :last_name, :locale])
    |> validate_required([:name, :email])
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
  end

  def register_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
  end

  # Mutations

  def find_or_create_by_provider(user_params, provider_params) do
    case UserProvider.find_user(provider_params) do
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
