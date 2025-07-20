import Config

if config_env() == :prod do
  role = System.get_env("ROLE", "isolate")

  case role do
    "api" ->
      config :rinha,
        port: System.get_env("PORT", "4000") |> String.to_integer(),
        role: role,
        queue_address: {Queue, :worker@worker}

    "worker" ->
      config :rinha,
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
        role: role

    _ ->
      config :rinha,
        port: System.get_env("PORT", "4000") |> String.to_integer(),
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
        role: role
  end
end
