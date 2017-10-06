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

  # Changesets

  def changeset(struct, params) do
    struct
    |> cast(params, [:id, :name, :type])
    |> validate_required(:name)
    |> update_change(:type, &downcase/1)
    |> validate_inclusion(:type, ["guest", "user"])
  end

  defp downcase(value) when is_bitstring(value), do: String.downcase(value)
  defp downcase(_), do: nil

  # Queries

  def get(id), do: Repo.get(User, id)

  def get_by(params) when is_map(params), do: get_by(Enum.into(params, []))
  def get_by(params), do: Repo.get_by(User, params)

  def get_or_create_by(params) do
    case get_by(params) do
      nil -> create(params)
      user -> {:ok, user}
    end
  end

  # Mutations

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

  # Data Functions

  def filter_params(:user, params) do
    Map.merge(
      Map.take(params, [:id, :name]),
      %{ type: "user" }
    )
  end
  def filter_params(:guest, params) do
    %{
      type: "guest",
      name: maybe_create_guest_name(params)
    }
  end

  defp maybe_create_guest_name(params) do
    case Map.get(params, "name", "") do
      "" -> "guest-" <> Util.String.random(6)
      name -> name
    end
  end
end
