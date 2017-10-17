defmodule Util.String do
  def random(length) do
		length
		|> :crypto.strong_rand_bytes
		|> Base.url_encode64
		|> binary_part(0, length)
  end

  def slugify(name) when is_bitstring(name) do
    name
    |> String.downcase
    |> spaces_to_dashes
    |> remove_non_alphanumeric
  end
  def slugify(_), do: nil

  defp spaces_to_dashes(value), do: Regex.replace(~r/[\ ]/, value, "-")
  defp remove_non_alphanumeric(value), do: Regex.replace(~r/[^a-zA-Z0-9-]/, value, "")
end
