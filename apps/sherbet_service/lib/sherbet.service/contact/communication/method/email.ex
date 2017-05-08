defmodule Sherbet.Service.Contact.Communication.Method.Email do
    @moduledoc """
      Support email contacts.
    """

    @behaviour Sherbet.Service.Contact.Communication.Method

    alias Sherbet.Service.Contact.Communication.Method.Email
    require Logger
    import Ecto.Query

    #todo: should error reasons expose changeset.errors?

    def add(identity, email) do
        contact =
            %Email.Model{}
            |> Email.Model.insert_changeset(%{ identity: identity, email: email })
            |> Sherbet.Service.Repo.insert

        case contact do
            { :ok, _ } -> :ok
            { :error, changeset } ->
                Logger.debug("add: #{inspect(changeset.errors)}")
                { :error, "Failed to add email contact" }
        end
    end

    def remove(identity, email) do
        query = from contact in Email.Model,
            where: contact.identity == ^identity and contact.email == ^email

        case Sherbet.Service.Repo.delete_all(query) do
            { 0, _ } ->
                Logger.debug("remove: #{identity}, #{email}")
                { :error, "Failed to remove the contact" }
            _ -> :ok
        end
    end

    def verified?(identity, email) do
        query = from contact in Email.Model,
            where: contact.identity == ^identity and contact.email == ^email,
            select: contact.verified

        case Sherbet.Service.Repo.one(query) do
            nil -> { :error, "Email does not exist" }
            verified -> { :ok, verified }
        end
    end

    def contacts(identity) do
        query = from contact in Email.Model,
            where: contact.identity == ^identity,
            select: { contact.verified, contact.email }

        {
            :ok,
            Sherbet.Service.Repo.all(query)
            |> Enum.map(fn
                { true, email } -> { :verified, email }
                { false, email } -> { :unverified, email }
            end)
        }
    end

    def request_removal(email) do
        query = from contact in Email.Model,
            where: contact.email == ^email,
            select: { contact.id, contact.verified }

        with { :email, { id, false } } <- { :email, Sherbet.Service.Repo.one(query) },
             { :key, { :ok, _ } } <- { :key, Sherbet.Service.Repo.insert(Email.RemovalKey.Model.changeset(%Email.RemovalKey.Model{}, %{ email_id: id, key: generate_key() })) } do
                #todo: send unique key to the email (use mailing service to send the message)
                :ok
        else
            { :email, nil } -> { :error, "Email does not exist" }
            { :email, { _, true } } -> { :error, "Email is verified" }
            { :key, { :error, changeset } } ->
                Logger.debug("request_verification: #{inspect(changeset.errors)}")
                { :error, "Failed to create removal key for email" }
        end
    end

    def finalise_removal(email, key) do
        query = from removal in Email.RemovalKey.Model,
            where: removal.key == ^key,
            join: contact in Email.Model, on: contact.id == removal.email_id and contact.email == ^email,
            select: contact

        case Sherbet.Service.Repo.one(query) do
            nil -> { :error, "Invalid removal attempt" }
            %Email.Model{ verified: true } -> { :error, "Email is verified" }
            contact = %Email.Model{ verified: false, id: id } ->
                case Sherbet.Service.Repo.delete(contact) do
                    { :ok, _ } -> :ok
                    { :error, changeset } ->
                        Logger.debug("finalise_removal: #{inspect(changeset.errors)}")
                        { :error, "Failed to remove email" }
                end
        end
    end

    def request_verification(identity, email) do
        query = from contact in Email.Model,
            where: contact.email == ^email and contact.identity == ^identity,
            select: { contact.id, contact.verified }

        with { :email, { id, false } } <- { :email, Sherbet.Service.Repo.one(query) },
             { :key, { :ok, _ } } <- { :key, Sherbet.Service.Repo.insert(Email.VerificationKey.Model.changeset(%Email.VerificationKey.Model{}, %{ email_id: id, key: generate_key() })) } do
                #todo: send unique key to the email (use mailing service to send the message)
                :ok
        else
            { :email, nil } -> { :error, "Email does not exist" }
            { :email, { _, true } } -> { :error, "Email is verified" }
            { :key, { :error, changeset } } ->
                Logger.debug("request_verification: #{inspect(changeset.errors)}")
                { :error, "Failed to create verification key for email" }
        end
    end

    def finalise_verification(identity, email, key) do
        query = from verification in Email.VerificationKey.Model,
            where: verification.key == ^key,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.identity == ^identity and contact.email == ^email,
            select: contact

        case Sherbet.Service.Repo.one(query) do
            nil -> { :error, "Invalid verification attempt" }
            %Email.Model{ verified: true } -> { :error, "Email is verified" }
            contact = %Email.Model{ verified: false, id: id } ->
                case Sherbet.Service.Repo.update(Email.Model.update_changeset(contact, %{ verified: true })) do
                    { :ok, _ } ->
                        query = from verification in Email.VerificationKey.Model,
                            where: verification.email_id == ^id

                        Sherbet.Service.Repo.delete_all(query)

                        :ok
                    { :error, changeset } ->
                        Logger.debug("finalise_verification: #{inspect(changeset.errors)}")
                        { :error, "Failed to verify email" }
                end
        end
    end

    defp generate_key() do
        :crypto.strong_rand_bytes(32)
        |> Base.url_encode64
    end
end
