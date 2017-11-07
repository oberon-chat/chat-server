defmodule ChatServer.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :state, :string
      add :slug, :string
      add :name, :string
      timestamps()
    end

    create index(:rooms, [:name])
    create index(:rooms, [:state])
    create index(:rooms, [:type])
    create unique_index(:rooms, [:name, :state], name: :rooms_name_state_index)
    create unique_index(:rooms, [:slug, :state], name: :rooms_slug_state_index)
  end
end
