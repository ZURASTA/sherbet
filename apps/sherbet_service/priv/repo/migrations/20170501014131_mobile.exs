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

            add :primary, :boolean,
                default: false,
                null: false

            timestamps()
        end

        create index(:mobiles, [:identity], unique: false)
        create index(:mobiles, [:mobile], unique: true)
        create index(:mobiles, [:identity, :primary], unique: true, where: "mobiles.primary IS true", name: :mobiles_primary_contact_index)
    end
end
