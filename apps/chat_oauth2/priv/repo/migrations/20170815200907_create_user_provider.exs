defmodule ChatOAuth2.Repo.Migrations.CreateUserProvider do
  use Ecto.Migration

  def change do
    create table(:user_providers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :provider_id, :string
      add :client_id, :string
      add :access_token, :string
      add :expires_at, :integer
      add :refresh_token, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
      timestamps()
    end

    create index(:user_providers, [:type])
    create unique_index(:user_providers, [:type, :provider_id])
  end
end
