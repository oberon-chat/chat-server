defmodule ChatServer.Schema.StarredMessage do
  use ChatServer.Schema

  @derive {Poison.Encoder, except: [:__meta__]}

  @primary_key false

  schema "starred_messages" do
    belongs_to :user, ChatServer.Schema.User
    belongs_to :message, ChatServer.Schema.Message
    timestamps()
  end

  def create(params) do
    %StarredMessage{}
    |> changeset(params)
    |> Repo.insert
  end

  def delete(%StarredMessage{} = starred_message) do
    Repo.delete(starred_message)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:message_id, :user_id])
    |> assoc_constraint(:message)
    |> assoc_constraint(:user)
  end
end
