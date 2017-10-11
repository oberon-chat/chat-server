defmodule ChatServer.Repo.Migrations.CreateUsersRooms do
  use Ecto.Migration

  def change do
    create table(:users_rooms, primary_key: false) do
      add :room_id, references(:rooms, type: :uuid)
      add :user_id, references(:users, type: :uuid)
    end

    create unique_index(:users_rooms, [:user_id, :room_id], name: :users_rooms_index)
  end
end
