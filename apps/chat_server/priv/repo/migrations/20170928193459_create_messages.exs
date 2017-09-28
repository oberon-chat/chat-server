defmodule ChatServer.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text
      add :edited, :boolean
      add :room_id, references(:rooms, on_delete: :delete_all, type: :uuid)
      add :user_id, references(:users, on_delete: :nothing, type: :uuid)
      timestamps()
    end
  end
end
