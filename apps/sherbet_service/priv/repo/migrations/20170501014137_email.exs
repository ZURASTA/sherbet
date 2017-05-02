defmodule Sherbet.Service.Repo.Migrations.Email do
    use Ecto.Migration

    def change do
        create table(:emails) do
            add :identity, :uuid,
                null: false

            add :email, :string,
                null: false

            add :verified, :boolean,
                default: false,
                null: false

            timestamps()
        end

        create index(:emails, [:identity], unique: false)
        create index(:emails, [:email], unique: true)
    end
end
