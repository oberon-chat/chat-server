defmodule ChatServer.RoomInitializer do
  use GenServer

  alias ChatServer.Schema
  alias ChatServer.StartRoom

  defmodule State do
    defstruct started: []
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %State{started: start_rooms()}}
  end

  defp start_rooms do
    Schema.Room.all
    |> Enum.map(&StartRoom.call/1)
  end
end
