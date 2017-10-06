defmodule ChatServer.Schema.Room do
  use ChatServer.Schema

  @derive {
    Poison.Encoder,
    except: [:__meta__, :inserted_at, :updated_at]
  }

  @default_type "persistent"
  @default_status "active"

  schema "rooms" do
    field :type, :string, default: @default_type
    field :status, :string, default: @default_status
    field :slug, :string
    field :name, :string

    has_many :messages, ChatServer.Schema.Message

    timestamps()
  end

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :slug, :status, :type])
    |> update_change(:status, &downcase/1)
    |> update_change(:type, &downcase/1)
    |> validate_required(:name)
    |> validate_inclusion(:status, ["active", "archived"])
    |> validate_inclusion(:type, ["persistent", "transient"])
    |> unique_constraint(:name, name: :rooms_name_status_index)
    |> create_slug
  end

  defp downcase(value) when is_bitstring(value), do: String.downcase(value)
  defp downcase(_), do: nil

  def create_slug(set) do
    with nil <- Map.get(set.data, :slug, nil),
         name <- Map.get(set.changes, :name, nil) do
      put_change(set, :slug, Util.String.slugify(name))
    else
      _ -> set
    end
  end

  # Queries

  def all, do: Repo.all(__MODULE__)

  def get_by(params) when is_map(params), do: get_by(Enum.into(params, []))
  def get_by(params), do: Repo.get_by(Room, params)

  def get_or_create_by(params) do
    case get_by(params) do
      nil -> create(params)
      room -> {:ok, room}
    end
  end

  # Mutations

  def create(params) do
    %Room{}
    |> changeset(params)
    |> Repo.insert
  end
end
