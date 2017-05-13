defmodule Sherbet.Service.Contact.Communication.Method.EmailTest do
    use Sherbet.Service.Case

    alias Sherbet.Service.Contact.Communication.Method.Email

    setup do
        { :ok, %{ identity: Ecto.UUID.generate() } }
    end

    test "associate email with identity", %{ identity: identity } do
        assert :ok == Email.add(identity, "foo@foo")

        assert { :ok, [{ :unverified, :secondary, "foo@foo" }] } == Email.contacts(identity)
        assert { :ok, false } == Email.verified?(identity, "foo@foo")
    end

    test "associate pre-existing email with identity", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")
        assert { :error, "Failed to add email contact" } == Email.add(identity, "foo@foo")
    end

    test "remove verified email from identity", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        :ok = Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Email.finalise_verification(identity, "foo@foo", key)

        assert :ok == Email.remove(identity, "foo@foo")

        assert{ :ok, [] } == Email.contacts(identity)
    end

    test "remove email from identity", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.remove(identity, "foo@foo")

        assert { :ok, [] } == Email.contacts(identity)
    end

    test "remove non-existing email from identity", %{ identity: identity } do
        assert { :error, "Failed to remove the contact" } == Email.remove(identity, "fake@foo")
    end

    test "remove unverified email per request with valid key", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_removal("foo@foo")

        query = from removal in Email.RemovalKey.Model,
            join: contact in Email.Model, on: contact.id == removal.email_id and contact.email == "foo@foo",
            select: removal.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Email.finalise_removal("foo@foo", key)

        assert { :ok, [] } == Email.contacts(identity)
    end

    test "remove verified email per request", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        :ok = Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Email.finalise_verification(identity, "foo@foo", key)

        assert { :error, "Email is verified" } == Email.request_removal("foo@foo")
    end

    test "remove unverified email per request with invalid key", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_removal("foo@foo")
        assert { :error, "Invalid removal attempt" } == Email.finalise_removal("foo@foo", "")

        assert { :ok, [{ :unverified, :secondary, "foo@foo" }] } == Email.contacts(identity)
    end

    test "remove non-existent email per request", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert { :error, "Email does not exist" } == Email.request_removal("fake@foo")
    end

    test "verify unverified email per request for identity with valid key", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Email.finalise_verification(identity, "foo@foo", key)

        assert { :ok, [{ :verified, :secondary, "foo@foo" }] } == Email.contacts(identity)
        assert { :ok, true } == Email.verified?(identity, "foo@foo")
    end

    test "verify verified email per request for identity", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        :ok = Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Email.finalise_verification(identity, "foo@foo", key)

        assert { :error, "Email is verified" } == Email.request_verification(identity, "foo@foo")
    end

    test "verify unverified email per request for wrong identity with valid key", %{ identity: identity } do
        identity2 = Regex.replace(~r/[\da-f]/, identity, fn
            "0", _ -> "1"
            "1", _ -> "2"
            "2", _ -> "3"
            "3", _ -> "4"
            "4", _ -> "5"
            "5", _ -> "6"
            "6", _ -> "7"
            "7", _ -> "8"
            "8", _ -> "9"
            "9", _ -> "a"
            "a", _ -> "b"
            "b", _ -> "c"
            "c", _ -> "d"
            "d", _ -> "e"
            "e", _ -> "f"
            "f", _ -> "0"
        end)

        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert { :error, "Invalid verification attempt" } == Email.finalise_verification(identity2, "foo@foo", key)

        assert { :ok, [{ :unverified, :secondary, "foo@foo" }] } == Email.contacts(identity)
        assert { :ok, false } == Email.verified?(identity, "foo@foo")
    end

    test "verify unverified email per request for identity with invalid key", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_verification(identity, "foo@foo")
        assert { :error, "Invalid verification attempt" } == Email.finalise_verification(identity, "foo@foo", "")

        assert { :ok, [{ :unverified, :secondary, "foo@foo" }] } == Email.contacts(identity)
        assert { :ok, false } == Email.verified?(identity, "foo@foo")
    end

    test "verify non-existent email per request for identity", %{ identity: identity } do
        :ok = Email.add(identity, "foo@foo")

        assert { :error, "Email does not exist" } == Email.request_verification(identity, "fake@foo")
    end

    test "setting email priority", %{ identity: identity } do
        assert :ok == Email.add(identity, "foo@foo")
        assert :ok == Email.make_primary(identity, "foo@foo")
        assert { :ok, { :unverified, "foo@foo" } } == Email.primary_contact(identity)

        assert :ok == Email.add(identity, "foo@foo2")
        assert { :ok, { :unverified, "foo@foo" } } == Email.primary_contact(identity)
        assert :ok == Email.make_primary(identity, "foo@foo2")
        assert { :ok, { :unverified, "foo@foo2" } } == Email.primary_contact(identity)

        assert { :error, "Email does not exist" } == Email.make_primary(identity, "fake@foo")
        assert { :ok, { :unverified, "foo@foo2" } } == Email.primary_contact(identity)

        identity2 = Regex.replace(~r/[\da-f]/, identity, fn
            "0", _ -> "1"
            "1", _ -> "2"
            "2", _ -> "3"
            "3", _ -> "4"
            "4", _ -> "5"
            "5", _ -> "6"
            "6", _ -> "7"
            "7", _ -> "8"
            "8", _ -> "9"
            "9", _ -> "a"
            "a", _ -> "b"
            "b", _ -> "c"
            "c", _ -> "d"
            "d", _ -> "e"
            "e", _ -> "f"
            "f", _ -> "0"
        end)

        assert { :error, "Email does not exist" } == Email.make_primary(identity2, "foo@foo")
        assert { :ok, { :unverified, "foo@foo2" } } == Email.primary_contact(identity)
    end
end
