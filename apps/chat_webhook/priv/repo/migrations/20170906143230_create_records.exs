defmodule ChatWebhook.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, :binary_id
      add :active, :boolean
      add :name, :string
      add :description, :text
      add :topics, {:array, :string}
      add :client_type, :string
      add :client_options, :map

      timestamps()
    end

    create index(:records, [:id])
    create index(:records, [:user_id])

    execute "CREATE INDEX client_options_index ON records USING gin(client_options jsonb_path_ops);"
  end
end
