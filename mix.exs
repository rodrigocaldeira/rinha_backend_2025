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

  def application do
    [
      extra_applications: [:logger, :inets],
      mod: {Rinha.Application, []}
    ]
  end

  defp deps, do: [{:bandit, "~> 1.7.0"}]
end
