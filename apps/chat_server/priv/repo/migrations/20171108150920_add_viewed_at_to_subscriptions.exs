defmodule ChatServer.Repo.Migrations.AddViewedAtToSubscriptions do
  use Ecto.Migration

  def change do
    alter table("subscriptions") do
      add :viewed_at, :utc_datetime
    end
  end
end
