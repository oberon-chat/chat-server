defmodule ChatServer.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do

    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :status, :string
      timestamps()
    end

    create index(:rooms, [:name])
    create index(:rooms, [:status])
    create unique_index(:rooms, [:name, :status], name: :rooms_name_status_index)
  end
end
