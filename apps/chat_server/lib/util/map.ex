defmodule Util.Map do
  def with_atoms(map) do
    for {k, v} <- map, into: %{}, do: {String.to_atom(k), v}
  end
end
