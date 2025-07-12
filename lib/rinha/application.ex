defmodule Rinha.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    role = Application.get_env(:rinha, :role)

    children = create_children(role)

    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp create_children("api") do
    port = Application.get_env(:rinha, :port)

    [
      {Bandit, plug: Rinha.Router, port: port},
      {Task.Supervisor, name: Rinha.TaskSupervisor}
    ]
  end

  defp create_children("worker") do
    services = Application.get_env(:rinha, :services)
    worker_pool_size = Application.get_env(:rinha, :worker_pool_size)

    [
      Rinha.Repo,
      {Ecto.Migrator, repos: Application.fetch_env!(:rinha, :ecto_repos)},
      {Rinha.Processor.Services, services},
      Rinha.Queue,
      {Rinha.WorkerPool, size: worker_pool_size, job: &Rinha.pay/0},
      {Rinha.Worker,
       name: ServicesHealthWorker,
       job: fn ->
         Process.sleep((:rand.uniform(5) + 5) * 1_000)
         Rinha.Processor.Client.service_health()
       end},
      {Task.Supervisor, name: Rinha.TaskSupervisor}
    ]
  end

  defp create_children(_) do
    port = Application.get_env(:rinha, :port)
    services = Application.get_env(:rinha, :services)
    worker_pool_size = Application.get_env(:rinha, :worker_pool_size)

    [
      {Bandit, plug: Rinha.Router, port: port},
      Rinha.Repo,
      {Ecto.Migrator, repos: Application.fetch_env!(:rinha, :ecto_repos)},
      {Rinha.Processor.Services, services},
      Rinha.Queue,
      {Rinha.WorkerPool, size: worker_pool_size, job: &Rinha.pay/0},
      {Rinha.Worker,
       name: ServicesHealthWorker,
       job: fn ->
         Process.sleep((:rand.uniform(5) + 5) * 1_000)
         Rinha.Processor.Client.service_health()
       end}
    ]
  end
end
