defmodule Sherbet.Service.Repo.Migrations.Email.RemovalKey do
    use Ecto.Migration

    def change do
        create table(:email_removal_keys) do
            add :email_id, references(:emails, on_delete: :delete_all),
                null: false

            add :key, :string,
                null: false

            timestamps()
        end

        create index(:email_removal_keys, [:key], unique: false)
    end
end
