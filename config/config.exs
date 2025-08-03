import Config

config :rinha,
  port: System.get_env("PORT", "4000") |> String.to_integer(),
  worker_pool_size: System.get_env("WORKER_POOL_SIZE", "4") |> String.to_integer(),
  services: [
    {
      System.get_env("DEFAULT_SERVICE_NAME", "default"),
      System.get_env("DEFAULT_SERVICE_URL", "http://localhost:8001"),
      false,
      0
    },
    {
      System.get_env("FALLBACK_SERVICE_NAME", "fallback"),
      System.get_env("FALLBACK_SERVICE_URL", "http://localhost:8002"),
      false,
      0
    }
  ]

import_config "#{config_env()}.exs"
