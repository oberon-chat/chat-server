defmodule ChatServer.Auth do
  def valid?(token) when is_bitstring(token),
    do: auth_client().valid?(token)

  defp auth_client do
    Application.fetch_env!(:chat_server, :auth_client)
  end
end
