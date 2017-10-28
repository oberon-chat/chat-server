defmodule ChatServer.Schema.Message do
  use ChatServer.Schema

  @derive {Poison.Encoder, except: [:__meta__]}

  schema "messages" do
    field :body, :string
    field :edited, :boolean, default: false

    belongs_to :room, Schema.Room
    belongs_to :user, Schema.User

    many_to_many :starred_message_users, Schema.User, join_through: "starred_messages", on_delete: :delete_all, on_replace: :delete

    timestamps()
  end

  # Changesets

  def changeset(struct, params) do
    struct
    |> cast(params, [:body, :edited, :room_id, :user_id])
    |> validate_required(:body)
    |> assoc_constraint(:room)
    |> assoc_constraint(:user)
  end

  # Queries

  def get(id) do
    Repo.get(Message, id)
  end

  # Mutations

  def create(params) do
    %Message{}
    |> changeset(params)
    |> Repo.insert
  end

  def update(%Message{} = message, params) do
    message
    |> changeset(params)
    |> Repo.update
  end

  def delete(%Message{} = message) do
    Repo.delete(message)
  end
end
