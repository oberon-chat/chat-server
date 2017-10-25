defmodule ChatServer.Repo.Migrations.AddIdToStarredMessageTable do
  use Ecto.Migration

  def change do
    alter table(:starred_messages) do
      add :id, :binary_id, primary_key: true
    end
  end
end
