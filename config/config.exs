import Config

config :rinha, ecto_repos: [Rinha.Repo]

config :rinha, Rinha.Repo,
  database: Path.expand("../rinha_dev.db", __DIR__),
  pool_size: System.get_env("DATABASE_POOL_SIZE", "10") |> String.to_integer(),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :rinha,
  port: System.get_env("PORT", "8080") |> String.to_integer(),
  worker_pool_size: System.get_env("WORKER_POOL_SIZE", "4") |> String.to_integer(),
  services: [
    %{
      name: System.get_env("DEFAULT_SERVICE_NAME", "default"),
      url: System.get_env("DEFAULT_SERVICE_URL", "http://localhost:8001")
    },
    %{
      name: System.get_env("FALLBACK_SERVICE_NAME", "fallback"),
      url: System.get_env("FALLBACK_SERVICE_URL", "http://localhost:8002")
    }
  ],
  role: System.get_env("ROLE", "POLYVALENT")

import_config "#{config_env()}.exs"
