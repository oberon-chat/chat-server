defmodule ChatCallback.CallbackInitializer do
  use GenServer

  alias ChatCallback.CallbackSupervisor
  alias ChatCallback.Record
  alias ChatCallback.Repo

  defmodule State do
    defstruct started: []
  end

  def start_link do
    callbacks = Repo.all(Record)

    GenServer.start_link(__MODULE__, callbacks)
  end

  def init(callbacks) do
    started = Enum.map(callbacks, &start_callback/1)

    {:ok, %State{started: started}}
  end

  defp start_callback(record) do
    case CallbackSupervisor.start_callback(record) do
      {:ok, pid} -> pid
      _ -> nil
    end
  end
end
