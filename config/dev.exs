import Config

config :rinha, Rinha.Repo,
  database: Path.expand("../rinha_dev.db", __DIR__),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :logger, level: :debug
