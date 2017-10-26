defmodule ChatServer.GetUser do
  alias ChatServer.Schema

  def call(id) when is_bitstring(id) do
    case Schema.User.get(id) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end
end
