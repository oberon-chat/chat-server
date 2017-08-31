defmodule ChatCallback.CallbackInitializer do
  use GenServer

  alias ChatCallback.Callback.Webhook

  defmodule State do
    defstruct started: []
  end

  def start_link do
    callbacks = [
      %{name: "webhook-test", topics: ["rooms"]}
    ]

    GenServer.start_link(__MODULE__, callbacks)
  end

  def init(callbacks) do
    started = Enum.map(callbacks, &start_callback/1)

    {:ok, %State{started: started}}
  end

  defp start_callback(options) do
    # case Supervisor.start_child(CallbackSupervisor, [opts])
    case Webhook.start(options) do
      {:ok, pid} -> pid
      _ -> nil
    end
  end
end
