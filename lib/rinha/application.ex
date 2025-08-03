defmodule Rinha.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    clusterize()
    start_tables()
    children = create_children()
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp start_tables do
    table_config = [
      :ordered_set,
      :public,
      :named_table,
      decentralized_counters: true,
      write_concurrency: true
    ]

    :ets.new(:rinha_queue, table_config)
    :ets.new(:rinha_db, table_config)
  end

  defp clusterize() do
    init_cluster()
  end

  defp init_cluster do
    cluster_node = System.get_env("CLUSTER_NODE")

    if not is_nil(cluster_node) do
      if not Node.connect(String.to_atom(cluster_node)) do
        Process.sleep(1_000)
        init_cluster()
      end
    end
  end

  defp create_children do
    port = Application.get_env(:rinha, :port)
    services = Application.get_env(:rinha, :services)
    worker_pool_size = Application.get_env(:rinha, :worker_pool_size)

    [
      {Bandit, plug: Rinha.Router, port: port},
      {Rinha.Processor.Services, services},
      {Rinha.WorkerPool, size: worker_pool_size, job: &Rinha.pay/0}
    ]
  end
end
