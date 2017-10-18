defmodule ChatServer.Schema.Subscription do
  use ChatServer.Schema

  @derive {
    Poison.Encoder,
    except: [:__meta__, :inserted_at, :updated_at]
  }

  schema "subscriptions" do
    belongs_to :room, Schema.Room
    belongs_to :user, Schema.User

    timestamps()
  end

  # Changesets

  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> put_assoc(:user, Map.get(params, :user))
    |> put_assoc(:room, Map.get(params, :room))
  end

  # Queries

  def get(id), do: Repo.get(Subscription, id)

  def get_by(params), do: Repo.get_by(Subscription, params)

  # Mutations

  def create(params) do
    %Subscription{}
    |> changeset(params)
    |> Repo.insert
  end

  def delete(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end
end
