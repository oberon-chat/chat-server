defmodule ChatOAuth2.Schema do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias __MODULE__
      alias ChatOAuth2.Repo

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      def preload(resource, includes) do
        ChatOAuth2.Repo.preload(resource, includes)
      end
    end
  end
end
