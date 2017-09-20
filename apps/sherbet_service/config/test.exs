use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

import_config Path.join(Mix.Project.deps_path(), "cake_service/apps/cake_service/config/config.exs")
