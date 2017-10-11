defmodule ChatServer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :chat_server,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {ChatServer.Application, []},
      applications: [
        :logger,
        :postgrex,
        :ecto,
        :scrivener_ecto,
        :chat_pubsub
      ]
    ]
  end

  defp deps do
    [
      {:chat_pubsub, in_umbrella: true},
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.13"},
      {:ex_machina, "~> 2.1", only: :test},
      {:scrivener_ecto, "~> 1.2"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    ["test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
