defmodule ChatServer.Schema.Message do
  use ChatServer.Schema

  alias __MODULE__
  alias ChatServer.Repo

  schema "messages" do
    field :body, :string
    field :edited, :boolean, default: false

    belongs_to :room, ChatServer.Schema.Room
    belongs_to :user, ChatServer.Schema.User

    timestamps()
  end

  def create(params) do
    %Message{}
    |> changeset(params)
    |> Repo.insert
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:body, :edited, :room_id, :user_id])
    |> validate_required(:body)
    # |> assoc_constraint(:room)
  end
end
