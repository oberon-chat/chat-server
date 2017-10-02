defmodule ChatServer.Schema.User do
  use ChatServer.Schema

  @derive {
    Poison.Encoder,
    except: [:__meta__, :inserted_at, :updated_at]
  }

  @default_type "user"

  schema "users" do
    field :name, :string
    field :type, :string, default: @default_type

    timestamps()
  end

  def get(id) do
    Repo.get(User, id)
  end

  def get_by(key, value) do
    params = Keyword.put([], key, value)
    Repo.get_by(User, params)
  end

  def get_or_create_by(key, value, params) do
    case get_by(key, value) do
      nil -> create(params)
      user -> {:ok, user}
    end
  end

  def create(params) do
    %User{}
    |> changeset(params)
    |> Repo.insert
  end

  def update(%User{} = user, params) do
    user
    |> changeset(params)
    |> Repo.update
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name, :type])
    |> validate_required(:name)
    |> update_change(:type, &downcase/1)
    |> validate_inclusion(:type, ["guest", "user"])
  end

  defp downcase(value) when is_bitstring(value), do: String.downcase(value)
  defp downcase(_), do: nil
end
