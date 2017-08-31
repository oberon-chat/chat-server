defmodule ChatPubSub.Mixfile do
  use Mix.Project

  def project do
    [app: :chat_pubsub,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [mod: {ChatPubSub.Application, []},
     applications: [:logger, :phoenix, :phoenix_pubsub]]
  end

  defp deps do
    [{:phoenix, "~> 1.3"},
     {:phoenix_pubsub, "~> 1.0"}]
  end
end
