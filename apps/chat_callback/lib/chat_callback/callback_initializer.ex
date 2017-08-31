defmodule ChatCallback.CallbackInitializer do
  use GenServer

  alias ChatCallback.Callback

  defmodule State do
    defstruct started: []
  end

  def start_link do
    callbacks = ["callback-example"]

    GenServer.start_link(__MODULE__, callbacks)
  end

  def init(callbacks) do
    started = Enum.map(callbacks, &start_callback/1)

    {:ok, %State{started: started}}
  end

  defp start_callback(options) do
    case Callback.start(options) do
      {:ok, pid} -> pid
      _ -> nil
    end
  end
end
