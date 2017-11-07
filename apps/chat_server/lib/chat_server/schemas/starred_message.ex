defmodule ChatServer.Schema.StarredMessage do
  use ChatServer.Schema

  schema "starred_messages" do
    belongs_to :user, ChatServer.Schema.User
    belongs_to :message, ChatServer.Schema.Message
    timestamps()
  end

  #Changesets

  def changeset(struct, params) do
    struct
    |> cast(params, [:message_id, :user_id])
    |> cast_assoc(:message)
    |> cast_assoc(:user)
  end

  # Queries

  def get(id) do
    Repo.get(StarredMessage, id)
  end

  def get_by_user(%Schema.User{} = user) do
     Map.get(user, :id)
     |> starred_messages_query
     |> Repo.all
  end

  def find_by_message_and_user(message, user) do
    user_id = Map.get(user, :id)
    message_id = Map.get(message, :id)
    starred_message_query(user_id, message_id)
  end

  defp starred_message_query(user_id, message_id) do
    Repo.get_by(StarredMessage, user_id: user_id, message_id: message_id)
  end

  defp starred_messages_query(user_id) do
    StarredMessage
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
  end

  #Mutations

  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert
  end

  def delete(%StarredMessage{} = starred_message) do
    Repo.delete(starred_message)
  end
end
