defmodule ChatOAuth2.GraphQL.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: ChatOAuth2.Repo

  object :session do
    field :token, :string
    field :token_expiration, :string
    field :user, :user
  end

  object :user do
    field :id, :id
    field :name, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :locale, :string
  end
end
