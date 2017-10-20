defmodule ChatServer.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :active, :boolean
      add :type, :string
      add :name, :string
      timestamps()
    end

    create index(:users, [:name])
  end
end
