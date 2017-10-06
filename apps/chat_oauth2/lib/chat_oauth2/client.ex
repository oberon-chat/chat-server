defmodule ChatOAuth2.Client do
  alias ChatOAuth2.Guardian.Serializer

  def valid?(token) do
    case decode(token) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  def get_user(token) do
    case decode(token) do
      {:ok, %{"sub" => sub}} -> Serializer.from_token(sub)
      {:error, _} -> {:error, "User not found"}
    end
  end

  defp decode(token), do: Guardian.decode_and_verify(token)
end
