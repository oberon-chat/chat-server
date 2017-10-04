defmodule ChatOAuth2Web.Router do
  use ChatOAuth2Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ChatOAuth2Web do
    pipe_through :api
  end
end
