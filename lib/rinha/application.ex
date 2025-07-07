defmodule Rinha.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit, plug: Rinha.Router},
      Rinha.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:rinha, :ecto_repos),
        skip: skip_migrations?()},
      Rinha.PubSub
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp skip_migrations? do
    System.get_env("RELEASE_NAME") != nil
  end
end
