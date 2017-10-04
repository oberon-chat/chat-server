defmodule ChatOAuth2Web.Router do
  use ChatOAuth2Web, :router

  pipeline :graphql do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug ChatOAuth2.Plug.Context
  end

  scope "/" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: ChatOAuth2.GraphQL.Schema
  end

  if Application.get_env(:chat_oauth2, :graphiql, false) do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: ChatOAuth2.GraphQL.Schema
	end
end
