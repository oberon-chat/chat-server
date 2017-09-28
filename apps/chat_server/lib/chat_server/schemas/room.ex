defmodule ChatServer.Schema.Room do
  use ChatServer.Schema

  @default_status "active"

  schema "rooms" do
    field :name, :string
    field :status, :string, default: @default_status

    has_many :messages, ChatServer.Schema.Message

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :status])
    |> update_change(:name, &downcase/1)
    |> update_change(:status, &downcase/1)
    |> validate_required(:name)
    |> validate_inclusion(:status, ["active", "archived"])
    |> unique_constraint(:name, name: :rooms_name_status_index)
  end

  defp downcase(value) when is_bitstring(value), do: String.downcase(value)
  defp downcase(_value), do: nil
end
