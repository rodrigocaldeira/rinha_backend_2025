defmodule Rinha.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha,
      version: "1.0.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: extra_applications(System.get_env("ROLE")),
      mod: {Rinha.Application, []}
    ]
  end

  def extra_applications("api"), do: [:logger]
  def extra_applications("worker"), do: [:logger, :inets]
  def extra_applications(_), do: [:logger, :runtime_tools, :inets]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps, do: [{:bandit, "~> 1.7.0"}]

  defp aliases, do: [setup: ["deps.get"]]
end
