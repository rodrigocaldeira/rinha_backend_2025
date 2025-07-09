defmodule Rinha.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit, plug: Rinha.Router},
      Rinha.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:rinha, :ecto_repos), skip: skip_migrations?()},
      {Rinha.Processor.Services,
        [
          %{name: "default", url: "http://localhost:8001"},
          %{name: "fallback", url: "http://localhost:8002"}
        ]
      },
      Rinha.Queue,
      {Rinha.Worker, name: QueueWorker, job: &Rinha.pay/0},
      {Rinha.Worker, name: ServicesHealthWorker, job: fn ->
        Process.sleep((:rand.uniform(5) + 5) * 1_000)
        Rinha.Processor.Client.service_health()
      end}
    ]

    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp skip_migrations? do
    System.get_env("RELEASE_NAME") != nil
  end
end
