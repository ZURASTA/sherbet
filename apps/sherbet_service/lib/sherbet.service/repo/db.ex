defmodule Sherbet.Service.Repo.DB do
    @repo Module.split(__MODULE__) |> Enum.split(-1) |> elem(0) |> Module.concat()

    def create() do
        @repo.__adapter__.storage_up(@repo.config())
    end

    def migrate() do
        migrations = Application.app_dir(@repo.config()[:otp_app], "priv/repo/migrations")
        Ecto.Migrator.run(@repo, migrations, :up, all: true)
    end

    def drop() do
        @repo.__adapter__.storage_down(@repo.config())
    end
end
