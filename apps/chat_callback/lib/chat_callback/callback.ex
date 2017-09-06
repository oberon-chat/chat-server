defmodule ChatCallback.Callback do
  def start_link(module, opts) do
    GenServer.start_link(module, [opts])
  end

  defmacro __using__(_opts) do
    quote location: :keep do
      use GenServer

      alias ChatCallback.CallbackSupervisor

      defmodule State do
        defstruct [:id, :client_opts, :name, :topics]
      end

      def subscribe(pid, topic) do
        GenServer.call(pid, {:subscribe, topic})
      end

      def unsubscribe(pid, topic) do
        GenServer.call(pid, {:unsubscribe, topic})
      end

      def init([opts]) do
        send(self(), :init_subscribe)

        {:ok, %State{} |> Map.merge(opts)}
      end

      def handle_call({:subscribe, topic}, _from, %State{topics: topics} = state) do
        if topic in topics do
          {:reply, :ok, state}
        else
          :ok = ChatPubSub.subscribe(topic)
          {:reply, :ok, %{state | topics: [topic] ++ topics}}
        end
      end

      def handle_call({:unsubscribe, topic}, _from, %State{topics: topics} = state) do
        if topic in topics do
          :ok = ChatPubSub.unsubscribe(topic)
          {:reply, :ok, %{state | topics: [topic] -- topics}}
        else
          {:reply, :ok, state}
        end
      end

      def handle_info(:init_subscribe, %State{topics: topics} = state) do
        Enum.each topics, fn topic ->
          ChatPubSub.subscribe(topic)
        end

        {:noreply, state}
      end

      def handle_info(message, state) do
        __MODULE__.handle(message, state)
      end
    end
  end
end
