defmodule ChatServer.Schema.Group do
  use ChatServer.Schema

  @derive {
    Poison.Encoder,
    except: [:__meta__]
  }

  schema "groups" do
    field :name, :string
    field :slug, :string

    many_to_many :users, Schema.User, join_through: "users_groups"
  end

  # Changesets

  def changeset(struct, params) do
    struct
    |> cast(params, [:name, :slug])
    |> validate_required(:name)
    |> create_slug
    |> unique_constraint(:slug)
  end

  def create_slug(set) do
    with nil <- Map.get(set.data, :slug, nil),
         name <- Map.get(set.changes, :name, nil) do
      put_change(set, :slug, Util.String.slugify(name))
    else
      _ -> set
    end
  end

  # Mutations

  def create(params) do
    %Group{}
    |> changeset(params)
    |> Repo.insert
  end

  def create!(params) do
    %Group{}
    |> changeset(params)
    |> Repo.insert!
  end
end
