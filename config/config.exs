import Config

config :rinha, ecto_repos: [Rinha.Repo]

import_config "#{config_env()}.exs"
