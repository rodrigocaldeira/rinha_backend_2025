import Config

if config_env() == :prod do
  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      Please, set DATABASE_PATH env var
      """

  config :rinha, Rinha.Repo,
    database: database_path,
    pool_size: System.get_env("POOL_SIZE", "5") |> String.to_integer()

  config :rinha, services: 
    [
      %{
        name: System.fetch_env!("DEFAULT_SERVICE_NAME"),
        url: System.fetch_env!("DEFAULT_SERVICE_URL")
      },
      %{
        name: System.fetch_env!("FALLBACK_SERVICE_NAME"),
        url: System.fetch_env!("FALLBACK_SERVICE_URL")
      }
    ]
end

