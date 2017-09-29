defmodule ChatServer.Event.RoomCreated do
  @derive {Poison.Encoder, only: [room: [:id, :slug, :name]]}

  defstruct [:room]
end
