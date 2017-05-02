defmodule Sherbet.Service.Repo.Migrations.Mobile do
    use Ecto.Migration

    def change do
        create table(:mobiles) do
            add :identity, :uuid,
                null: false

            add :mobile, :string,
                null: false

            add :verified, :boolean,
                default: false,
                null: false

            timestamps()
        end

        create index(:mobiles, [:identity], unique: false)
        create index(:mobiles, [:mobile], unique: true)
    end
end
