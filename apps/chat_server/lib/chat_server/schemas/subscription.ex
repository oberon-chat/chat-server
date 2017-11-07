defmodule ChatServer.Schema.Subscription do
  use ChatServer.Schema

  @allowed_states ["open", "muted", "closed", "ignored"]
  @default_state "open"

  schema "subscriptions" do
    field :state, :string, default: @default_state

    belongs_to :room, Schema.Room
    belongs_to :user, Schema.User

    timestamps()
  end

  # Changesets

  def changeset(struct, params) do
    struct
    |> cast(params, [:state])
    |> update_change(:state, &downcase/1)
    |> validate_inclusion(:state, @allowed_states)
    |> put_assoc(:user, Map.get(params, :user))
    |> put_assoc(:room, Map.get(params, :room))
  end

  def update_changeset(struct, params) do
    struct
    |> cast(params, [:state])
    |> update_change(:state, &downcase/1)
    |> validate_inclusion(:state, @allowed_states)
  end

  defp downcase(value) when is_bitstring(value), do: String.downcase(value)
  defp downcase(_), do: nil

  # Queries

  def get(id), do: Repo.get(Subscription, id)

  def get_by(params), do: Repo.get_by(Subscription, params)

  # Mutations

  def create(params) do
    %Subscription{}
    |> changeset(params)
    |> Repo.insert
  end

  def update(%Subscription{} = subscription, params) do
    subscription
    |> update_changeset(params)
    |> Repo.update
  end

  def delete(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end
end
