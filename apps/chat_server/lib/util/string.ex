defmodule Util.String do
  def random(length) do
		length
		|> :crypto.strong_rand_bytes
		|> Base.url_encode64
		|> binary_part(0, length)
  end

  def slugify(name) when is_bitstring(name), do: Regex.replace(~r/[^a-zA-Z-_]/, String.downcase(name), "")
  def slugify(_), do: nil
end
