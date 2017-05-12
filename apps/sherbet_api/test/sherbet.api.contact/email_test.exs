defmodule Sherbet.API.Contact.EmailTest do
    use Sherbet.Service.Case

    alias Sherbet.API.Contact.Email

    setup do
        { :ok, %{ identity: Ecto.UUID.generate() } }
    end

    test "associate email with identity", %{ identity: identity } do
        assert :ok == Email.add(identity, "foo@foo")
        assert { :ok, [{ :unverified, :secondary, "foo@foo" }] } == Email.contacts(identity)
        assert { :ok, false } == Email.verified?(identity, "foo@foo")
    end

    test "remove email from identity", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.remove(identity, "foo@foo")
        assert { :ok, [] } == Email.contacts(identity)
    end

    test "remove unverified email per request with valid key", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_removal("foo@foo")

        query = from removal in Sherbet.Service.Contact.Communication.Method.Email.RemovalKey.Model,
            join: contact in Sherbet.Service.Contact.Communication.Method.Email.Model, on: contact.id == removal.email_id and contact.email == "foo@foo",
            select: removal.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Email.finalise_removal("foo@foo", key)
        assert { :ok, [] } == Email.contacts(identity)
    end

    test "verify unverified email per request for identity with valid key", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_verification(identity, "foo@foo")

        query = from verification in Sherbet.Service.Contact.Communication.Method.Email.VerificationKey.Model,
            join: contact in Sherbet.Service.Contact.Communication.Method.Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Email.finalise_verification(identity, "foo@foo", key)
        assert { :ok, [{ :verified, :secondary, "foo@foo" }] } == Email.contacts(identity)
        assert { :ok, true } == Email.verified?(identity, "foo@foo")
    end

    test "setting email priority", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo", :primary)

        assert { :ok, { :unverified, "foo@foo" } } == Email.primary_contact(identity)

        assert :ok == Email.add(identity, "foo@foo2")
        assert { :ok, { :unverified, "foo@foo" } } == Email.primary_contact(identity)
        assert :ok == Email.make_primary(identity, "foo@foo2")
        assert { :ok, { :unverified, "foo@foo2" } } == Email.primary_contact(identity)
    end
end
