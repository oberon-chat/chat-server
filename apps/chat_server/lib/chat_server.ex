defmodule ChatServer do
  defimpl Poison.Encoder, for: Ecto.Association.NotLoaded do
    # Allows schemas with unloaded associations to be encoded. See:
    # - https://github.com/elixir-ecto/ecto/issues/840#issuecomment-257914677
    # - https://github.com/elixir-ecto/ecto/issues/840#issuecomment-296399706
    def encode(_struct, _options) do
      "null"
    end
  end
end
