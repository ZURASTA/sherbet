defmodule Sherbet.Service.Repo.Config do
    def setup(app, repo) do
        if Application.fetch_env(app, repo) == :error do
            Application.put_env(app, repo, case Mix.env do
                :dev -> [
                    adapter: Ecto.Adapters.Postgres,
                    username: "postgres",
                    password: "postgres",
                    database: to_string(app) <> "_dev",
                    hostname: "localhost",
                    pool_size: 10
                ]
                :test -> [
                    adapter: Ecto.Adapters.Postgres,
                    username: "postgres",
                    password: "postgres",
                    database: to_string(app) <> "_test",
                    hostname: "localhost",
                    pool: Ecto.Adapters.SQL.Sandbox
                ]
                _ -> nil
            end)
        end
    end
end
