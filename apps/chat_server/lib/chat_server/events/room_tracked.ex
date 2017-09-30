defmodule ChatServer.Event.RoomTracked do
  @derive {Poison.Encoder, only: [:last_message, room: [:id, :slug, :name]]}

  defstruct [:last_message, :name, :pid]
end
