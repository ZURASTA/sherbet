defmodule Sherbet.Service.Repo.Migrations.Mobile.RemovalKey do
    use Ecto.Migration

    def change do
        create table(:mobile_removal_keys) do
            add :mobile_id, references(:mobiles, on_delete: :delete_all),
                null: false

            add :key, :string,
                null: false

            timestamps()
        end

        create index(:mobile_removal_keys, [:key], unique: false)
    end
end
