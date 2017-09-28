defmodule ChatWebsocket.PageController do
  use ChatWebsocket, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
