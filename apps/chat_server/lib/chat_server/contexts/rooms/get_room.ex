defmodule ChatServer.GetRoom do
  alias ChatServer.Schema

  def call(id) when is_bitstring(id) do
    case Schema.Room.get(id) do
      nil -> {:error, "Room not found"}
      room -> {:ok, room}
    end
  end
  def call(opts) when is_list(opts) do
    case Schema.Room.get_by(opts) do
      nil -> {:error, "Room not found"}
      room -> {:ok, room}
    end
  end
end
