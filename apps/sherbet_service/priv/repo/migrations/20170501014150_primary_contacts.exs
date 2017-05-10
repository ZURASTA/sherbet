defmodule Sherbet.Service.Repo.Migrations.PrimaryContacts do
    use Ecto.Migration

    def change do
        create table(:primary_contacts) do
            add :identity, :uuid,
                null: false

            add :email_id, references(:emails)

            add :mobile_id, references(:mobiles)

            timestamps()
        end

        create index(:primary_contacts, [:identity], unique: true)
        create index(:primary_contacts, [:email_id], unique: true)
        create index(:primary_contacts, [:mobile_id], unique: true)
    end
end
