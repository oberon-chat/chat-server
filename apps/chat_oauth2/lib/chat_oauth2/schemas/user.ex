defmodule ChatOAuth2.User do
  use ChatOAuth2.Schema

  alias Ecto.Changeset
  alias Comeonin.Bcrypt

  schema "users" do
    field :name, :string
    field :first_name, :string
    field :last_name, :string
    field :locale, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :user_providers, ChatOAuth2.UserProvider
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :first_name, :last_name, :locale])
    |> validate_required([:name, :email])
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :password])
    |> validate_required([:name, :email])
    |> validate_length(:password, min: 12)
    |> put_password_hash()
  end

  def register_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end
