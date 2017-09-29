defmodule ChatServer.Schema.Room do
  use ChatServer.Schema

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

  def get_by(key, value) do
    params = Keyword.put([], key, value)
    Repo.get_by(Room, params)
  end

  def get_or_create_by(key, value, params) do
    case get_by(key, value) do
      nil -> create(params)
      room -> {:ok, room}
    end
  end

  def create(params) do
    %Room{}
    |> changeset(params)
    |> Repo.insert
  end

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

  defp create_slug(set) do
    with nil <- Map.get(set.data, :slug, nil),
         name <- Map.get(set.changes, :name, nil) do
      put_change(set, :slug, slugify(name))
    else
      _ -> set
    end
  end

  defp slugify(name) when is_bitstring(name), do: Regex.replace(~r/[^a-zA-Z-_]/, downcase(name), "")
  defp slugify(_), do: nil
end
