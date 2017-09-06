defmodule ChatCallback.CallbackInitializer do
  use GenServer

  alias ChatCallback.CallbackSupervisor

  alias ChatCallback.Callback.Slack
  alias ChatCallback.Callback.Webhook

  defmodule State do
    defstruct started: []
  end

  def start_link do
    callbacks = [
      %{type: "webhook", name: "webhook-test", topics: ["rooms"], client_opts: []},
      %{type: "slack", name: "slack-test", topics: ["rooms"], client_opts: [
        channels: ["#general", "#random", "@chrislaskey"],
        token: "..."
      ]}
    ]

    GenServer.start_link(__MODULE__, callbacks)
  end

  def init(callbacks) do
    started = Enum.map(callbacks, &start_callback/1)

    {:ok, %State{started: started}}
  end

  defp start_callback(opts) do
    module = get_module(opts[:type])

    case CallbackSupervisor.start_callback(module, opts) do
      {:ok, pid} -> pid
      _ -> nil
    end
  end

  defp get_module("slack"), do: Slack
  defp get_module("webhook"), do: Webhook
end
