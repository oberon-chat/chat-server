defmodule ChatPubSubTest do
  use ExUnit.Case

  describe "subscribe/1" do
    test "subscribes the current process to the give topic" do
      :ok = ChatPubSub.subscribe("test")
      :ok = ChatPubSub.direct_broadcast!("test", {:message, "TEST!!!"})

      assert_receive {:message, "TEST!!!"}
    end
  end

  describe "unsubscribe/1" do
    test "unsubscribes the current process from the give topic" do
      :ok = ChatPubSub.subscribe("test")
      :ok = ChatPubSub.unsubscribe("test")
      :ok = ChatPubSub.direct_broadcast!("test", {:message, "TEST!!!"})

      refute_receive {:message, "TEST!!!"}
    end
  end
end
