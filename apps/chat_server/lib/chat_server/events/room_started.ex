defmodule ChatServer.Event.RoomStarted do
  @derive {Poison.Encoder, only: [room: [:id, :slug, :name]]}

  defstruct [:pid, :room]
end
