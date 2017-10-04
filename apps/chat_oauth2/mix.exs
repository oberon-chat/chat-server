defmodule ChatOAuth2.Mixfile do
  use Mix.Project

  def project do
    [
      app: :chat_oauth2,
      version: "0.1.0",
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
      mod: {ChatOAuth2.Application, []},
      applications: [
        :logger,
        :postgrex,
        :ecto,
        :chat_pubsub
      ]
    ]
  end

  defp deps do
    [
      {:chat_pubsub, in_umbrella: true},
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.13"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    ["test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
