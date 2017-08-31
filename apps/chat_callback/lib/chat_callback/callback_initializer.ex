defmodule ChatCallback.CallbackInitializer do
  use GenServer

  alias ChatCallback.Callback

  def start_link do
    callbacks = ["callback-example"]

    GenServer.start_link(__MODULE__, callbacks)
  end

  def init(callbacks) do
    Enum.map(callbacks, &start_callback/1)

    {:ok, %Callback{}}
  end

  defp start_callback(options) do
    Callback.start(options)
  end
end
