defmodule ChatServer.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :state, :string
      add :room_id, references(:rooms, type: :uuid), null: false
      add :user_id, references(:users, type: :uuid), null: false
      timestamps()
    end

    create unique_index(:subscriptions, [:user_id, :room_id], name: :subscriptions_user_room_index)
  end
end
