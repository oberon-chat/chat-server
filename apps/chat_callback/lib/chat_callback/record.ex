defmodule ChatCallback.Record do
  use ChatCallback.Schema

  schema "records" do
    field :user_id, :binary_id
    field :active, :boolean, default: true
    field :name, :string
    field :description, :string
    field :topics, {:array, :string}, default: []
    field :client_type, :string
    field :client_options, :map, default: %{}

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:active, :name, :description, :client_type, :client_options])
    |> validate_required(:name)
  end
end
