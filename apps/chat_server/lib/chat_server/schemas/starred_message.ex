defmodule ChatServer.Schema.StarredMessage do
  use ChatServer.Schema

  @derive {Poison.Encoder, except: [:__meta__]}

  @primary_key false

  schema "starred_messages" do
    belongs_to :user, ChatServer.Schema.User
    belongs_to :message, ChatServer.Schema.Message
    timestamps()
  end

  #Changesets

  def changeset(struct, params) do
    struct
    |> cast(params, [:message_id, :user_id])
    |> assoc_constraint(:message)
    |> assoc_constraint(:user)
  end

  # Queries

  def get(id) do
    Repo.get(StarredMessage, id)
  end

  def get(message_id) do
    Repo.get(StarredMessage, message_id: message_id)
  end

  def get_starred_messages(user) do
    user.id
    |> %{starred_messages: starred_messages_query}
  end

  defp starred_messages_query(user_id) do
    StarredMessage
    |> where(user_id: user_id)
    |> order_by(desc: :inserted_at)
  end

  #Mutations

  def create(params) do
    %StarredMessage{}
    |> changeset(params)
    |> Repo.insert
  end

  def delete(%StarredMessage{} = starred_message) do
    Repo.delete(starred_message)
  end
end
