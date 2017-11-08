defmodule ChatServer.Repo.Migrations.CreateStarredMessagesTable do
  use Ecto.Migration

  def change do
    create table(:starred_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :uuid)
      add :message_id, references(:messages, type: :uuid)
      timestamps()
    end

    create index(:starred_messages, [:message_id])
    create index(:starred_messages, [:user_id])
    create unique_index(:starred_messages, [:user_id, :message_id], name: :starred_messages_user_message_index)
  end
end
