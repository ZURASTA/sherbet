defmodule Sherbet.Service.Repo.DB do
    @repo Module.split(__MODULE__) |> Enum.split(-1) |> elem(0) |> Module.concat()
    @config @repo.config()

    def create() do
        @repo.__adapter__.storage_up(@config)
    end

    def migrate() do
        migrations = Application.app_dir(@config[:otp_app], "priv/repo/migrations")
        Ecto.Migrator.run(@repo, migrations, :up, all: true)
    end

    def drop() do
        @repo.__adapter__.storage_down(@config)
    end
end
