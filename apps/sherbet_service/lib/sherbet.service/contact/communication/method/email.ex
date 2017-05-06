defmodule Sherbet.Service.Contact.Communication.Method.Email do
    @moduledoc """
      Support email contacts.
    """

    @behaviour Sherbet.Service.Contact.Communication.Method

    alias Sherbet.Service.Contact.Communication.Method
    require Logger
    import Ecto.Query

    #todo: should error reasons expose changeset.errors?

    def add(identity, email) do
        contact =
            %Method.Email.Model{}
            |> Method.Email.Model.insert_changeset(%{ identity: identity, email: email })
            |> Sherbet.Service.Repo.insert

        case contact do
            { :ok, _ } -> :ok
            { :error, changeset } ->
                Logger.debug("add: #{inspect(changeset.errors)}")
                { :error, "Failed to add email contact" }
        end
    end

    def remove(identity, email) do
        query = from contact in Method.Email.Model,
            where: contact.identity == ^identity and contact.email == ^email

        case Sherbet.Service.Repo.delete_all(query) do
            { 0, _ } ->
                Logger.debug("remove: #{identity}, #{email}")
                { :error, "Failed to remove the contact" }
            _ -> :ok
        end
    end

    def verified?(identity, email) do
        query = from contact in Method.Email.Model,
            where: contact.identity == ^identity and contact.email == ^email,
            select: contact.verified

        case Sherbet.Service.Repo.one(query) do
            nil -> { :error, "Email does not exist" }
            verified -> { :ok, verified }
        end
    end

    def contacts(identity) do
        query = from contact in Method.Email.Model,
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
        query = from contact in Method.Email.Model,
            where: contact.email == ^email,
            select: contact.verified

        case Sherbet.Service.Repo.one(query) do
            nil -> { :error, "Email does not exist" }
            true -> { :error, "Email is verified" }
            false ->
                #todo: generate and store unique key
                #todo: send unique key to the email (use mailing service to send the message)
                :ok
        end
    end

    def finalise_removal(email, key) do
        #todo: check key is associated with the given email
        query = from contact in Method.Email.Model,
            where: contact.email == ^email and contact.verified == false

        case Sherbet.Service.Repo.delete_all(query) do
            { 0, _ } ->
                { :error, "Failed to remove the contact" }
            _ -> :ok
        end
    end

    def request_verification(identity, email) do
        query = from contact in Method.Email.Model,
            where: contact.email == ^email,
            select: contact.verified

        case Sherbet.Service.Repo.one(query) do
            nil -> { :error, "Email does not exist" }
            true -> { :error, "Email is verified" }
            false ->
                #todo: generate and store unique key
                #todo: send unique key to the email (use mailing service to send the message)
                :ok
        end
    end

    def finalise_verification(identity, email, key) do
        #todo: check key is associated with the given email
        query = from contact in Method.Email.Model,
            where: contact.email == ^email,
            select: contact.verified

        case Sherbet.Service.Repo.one(query) do
            nil -> { :error, "Email does not exist" }
            true -> { :error, "Email is verified" }
            false ->
                :ok
        end
    end
end
