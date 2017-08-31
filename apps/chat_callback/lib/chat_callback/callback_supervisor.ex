defmodule ChatCallback.CallbackSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: (opts[:name] || __MODULE__))
  end

  def init(:ok) do
    supervise([
      worker(ChatCallback.Callback.Webhook, [], restart: :transient),
      # worker(ChatCallback.Callback, [], restart: :transient),
    ], strategy: :simple_one_for_one)
  end
end
