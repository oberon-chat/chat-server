defmodule ChatServer.Auth do
  def valid?(token), do: auth_client().valid?(token)

  def get_user(token), do: auth_client().get_user(token)

  defp auth_client do
    Application.fetch_env!(:chat_server, :auth_client)
  end
end
