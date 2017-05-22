use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

# Configure database
config :sherbet_service, Sherbet.Service.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: "postgres",
    password: "postgres",
    database: "sherbet_service_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox

import_config "../../../deps/cake_service/apps/cake_service/config/config.exs"
