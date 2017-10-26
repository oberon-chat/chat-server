defmodule ChatServer.Repo.Migrations.CreateUsersGroups do
  use Ecto.Migration

  def change do
    create table(:users_groups, primary_key: false) do
      add :group_id, references(:groups, type: :uuid), null: false
      add :user_id, references(:users, type: :uuid), null: false
    end

    create unique_index(:users_groups, [:user_id, :group_id], name: :users_groups_index)
  end
end
