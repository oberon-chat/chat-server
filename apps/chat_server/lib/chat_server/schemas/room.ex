defmodule ChatServer.Schema.Room do
  use ChatServer.Schema

  import Ecto.Query

  alias ChatServer.Schema.Room

  @derive {
    Poison.Encoder,
    except: [:__meta__, :inserted_at, :updated_at]
  }

  @default_type "public"
  @default_status "active"
  @default_messages_limit 50

  schema "rooms" do
    field :type, :string, default: @default_type
    field :status, :string, default: @default_status
    field :slug, :string
    field :name, :string

    has_many :messages, Schema.Message
    has_many :subscriptions, Schema.Subscription, on_delete: :delete_all
    has_many :users, through: [:subscriptions, :user]

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
    |> validate_inclusion(:type, ["public", "private", "direct", "support"])
    |> unique_constraint(:name, name: :rooms_name_status_index)
    |> unique_constraint(:slug, slug: :rooms_slug_status_index)
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

  def all, do: Repo.all(Room)

  def active do
    Room
    |> where(status: "active")
    |> Repo.all
  end

  def get(id), do: Repo.get(Room, id)

  def get_by(params), do: Repo.get_by(Room, params)

  def get_or_create_by(params) do
    case get_by(params) do
      nil -> create(params)
      room -> {:ok, room}
    end
  end

  def get_messages(id, opts \\ [])
  def get_messages(id, opts) when is_bitstring(id) do
    Room
    |> Repo.get(id)
    |> get_messages(opts)
  end
  def get_messages(%Room{} = room, opts) do
    room
    |> Repo.preload([messages: messages_query(opts)])
    |> Map.get(:messages)
    |> Repo.preload([:room, :user])
  end

  defp messages_query(opts \\ [])
  defp messages_query([inserted_after: inserted_after] = opts) do
    from m in Schema.Message,
    order_by: [desc: m.inserted_at],
    where: m.inserted_at > ^inserted_after,
    limit: ^Keyword.get(opts, :limit, @default_messages_limit)
  end
  defp messages_query(opts) do
    from m in Schema.Message,
    order_by: [desc: m.inserted_at],
    limit: ^Keyword.get(opts, :limit, @default_messages_limit)
  end

  def by_type(type) when is_bitstring(type), do: by_type([type])
  def by_type(types) when is_list(types) do
    Room
    |> where([r], r.type in ^types)
    |> Repo.all
  end

  # Mutations

  def create(params) do
    %Room{}
    |> changeset(params)
    |> Repo.insert
  end
end
