import Config

config :rinha, ecto_repos: [Rinha.Repo]

config :rinha,
  port: System.get_env("PORT", "8080") |> String.to_integer(),
  services: [
    %{
      name: System.get_env("DEFAULT_SERVICE_NAME", "default"),
      url: System.get_env("DEFAULT_SERVICE_URL", "http://localhost:8001")
    },
    %{
      name: System.get_env("FALLBACK_SERVICE_NAME", "fallback"),
      url: System.get_env("FALLBACK_SERVICE_URL", "http://localhost:8002")
    }
  ]

import_config "#{config_env()}.exs"
