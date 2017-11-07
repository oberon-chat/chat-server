defmodule ChatServer.Schema do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias __MODULE__
      alias ChatServer.Repo
      alias ChatServer.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      def preload(resource, includes) do
        ChatServer.Repo.preload(resource, includes)
      end

      defimpl Poison.Encoder, for: __MODULE__ do
        @doc """
        Defines a custom Poision encoder for each module. Used to:
        - Remove private keys like `__meta__`
        - Encode schemas with unloaded associations
        """
        def encode(%{__meta__: _, __struct__: _} = struct, options) do
          struct
          |> Map.drop([:__meta__])
          |> nil_unloaded_associations
          |> Poison.Encoder.Map.encode(options)
        end

        @doc """
        Allows schemas with unloaded associations to be encoded.

        Ecto implements a default Poison encoder that raises an exception when
        an unloaded association is found. Instead of raising, this module returns
        `nil`.

        See:
        - https://github.com/elixir-ecto/ecto/issues/840#issuecomment-257914677
        - https://github.com/elixir-ecto/ecto/issues/840#issuecomment-296399706
        """
        def nil_unloaded_associations(struct) do
          struct
          |> Map.from_struct
          |> Enum.map(fn({key, value}) ->
            case value do
              %Ecto.Association.NotLoaded{} -> {key, nil}
              _ -> {key, value}
            end
          end)
          |> Enum.into(%{})
        end
      end
    end
  end
end
