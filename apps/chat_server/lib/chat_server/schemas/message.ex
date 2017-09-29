defmodule ChatServer.Schema.Message do
  use ChatServer.Schema

  schema "messages" do
    field :body, :string
    field :edited, :boolean, default: false

    belongs_to :room, ChatServer.Schema.Room
    belongs_to :user, ChatServer.Schema.User

    timestamps()
  end

  def get(id) do
    Repo.get(Message, id)
  end

  def create(params) do
    %Message{}
    |> changeset(params)
    |> Repo.insert
  end

  def update(%Message{} = message, body) do
    message
    |> changeset(%{body: body, edited: true})
    |> Repo.update
  end

  def public(%Message{} = message) do
    message = Repo.preload(message, [:room, :user])

    %{
      id: message.id,
      user: message.user.name,
      body: message.body,
      edited: message.edited,
      room: message.room.name,
      timestamp: message.inserted_at
    }
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:body, :edited, :room_id, :user_id])
    |> validate_required(:body)
    # |> assoc_constraint(:room)
  end
end
