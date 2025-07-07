defmodule Rinha.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha,
      version: "1.0.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Rinha.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.7.0"},
      {:req, "~> 0.5.0"},
      {:ecto, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"}
    ]
  end
end
