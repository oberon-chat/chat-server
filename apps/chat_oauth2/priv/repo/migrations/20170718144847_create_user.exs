defmodule ChatOAuth2.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :locale, :string
      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
