defmodule ChatOAuth2.GraphQL.Schema do
  use Absinthe.Schema

  import_types ChatOAuth2.GraphQL.Types
  import_types ChatOAuth2.GraphQL.Types.User

  query do
    import_fields :user_queries
  end

  mutation do
    import_fields :user_mutations
  end
end
