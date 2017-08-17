use Mix.Config

config :sherbet_service,
    ecto_repos: [Sherbet.Service.Repo],
    mobile_key_length: 8,
    email_key_length: 32

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
