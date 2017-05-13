defmodule Sherbet.Service.Contact.Communication.Method.MobileTest do
    use Sherbet.Service.Case

    alias Sherbet.Service.Contact.Communication.Method.Mobile

    setup do
        { :ok, %{ identity: Ecto.UUID.generate() } }
    end

    test "associate mobile with identity", %{ identity: identity } do
        assert :ok == Mobile.add(identity, "+100")

        assert { :ok, [{ :unverified, :secondary, "+100" }] } == Mobile.contacts(identity)
        assert { :ok, false } == Mobile.verified?(identity, "+100")
    end

    test "associate pre-existing mobile with identity", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")
        assert { :error, "Failed to add mobile contact" } == Mobile.add(identity, "+100")
    end

    test "remove verified mobile from identity", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        :ok = Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Mobile.finalise_verification(identity, "+100", key)

        assert :ok == Mobile.remove(identity, "+100")

        assert { :ok, [] } == Mobile.contacts(identity)
    end

    test "remove mobile from identity", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.remove(identity, "+100")

        assert { :ok, [] } == Mobile.contacts(identity)
    end

    test "remove non-existing mobile from identity", %{ identity: identity } do
        assert { :error, "Failed to remove the contact" } == Mobile.remove(identity, "+999")
    end

    test "remove unverified mobile per request with valid key", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_removal("+100")

        query = from removal in Mobile.RemovalKey.Model,
            join: contact in Mobile.Model, on: contact.id == removal.mobile_id and contact.mobile == "+100",
            select: removal.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Mobile.finalise_removal("+100", key)

        assert { :ok, [] } == Mobile.contacts(identity)
    end

    test "remove verified mobile per request", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        :ok = Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Mobile.finalise_verification(identity, "+100", key)

        assert { :error, "Mobile is verified" } == Mobile.request_removal("+100")
    end

    test "remove unverified mobile per request with invalid key", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_removal("+100")
        assert { :error, "Invalid removal attempt" } == Mobile.finalise_removal("+100", "")

        assert { :ok, [{ :unverified, :secondary, "+100" }] } == Mobile.contacts(identity)
    end

    test "remove non-existent mobile per request", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert { :error, "Mobile does not exist" } == Mobile.request_removal("+999")
    end

    test "verify unverified mobile per request for identity with valid key", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Mobile.finalise_verification(identity, "+100", key)

        assert { :ok, [{ :verified, :secondary, "+100" }] } == Mobile.contacts(identity)
        assert { :ok, true } == Mobile.verified?(identity, "+100")
    end

    test "verify verified mobile per request for identity", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        :ok = Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Mobile.finalise_verification(identity, "+100", key)

        assert { :error, "Mobile is verified" } == Mobile.request_verification(identity, "+100")
    end

    test "verify unverified mobile per request for wrong identity with valid key", %{ identity: identity } do
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

        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert { :error, "Invalid verification attempt" } == Mobile.finalise_verification(identity2, "+100", key)

        assert { :ok, [{ :unverified, :secondary, "+100" }] } == Mobile.contacts(identity)
        assert { :ok, false } == Mobile.verified?(identity, "+100")
    end

    test "verify unverified mobile per request for identity with invalid key", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_verification(identity, "+100")
        assert { :error, "Invalid verification attempt" } == Mobile.finalise_verification(identity, "+100", "")

        assert { :ok, [{ :unverified, :secondary, "+100" }] } == Mobile.contacts(identity)
        assert { :ok, false } == Mobile.verified?(identity, "+100")
    end

    test "verify non-existent mobile per request for identity", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert { :error, "Mobile does not exist" } == Mobile.request_verification(identity, "+999")
    end

    test "setting mobile priority", %{ identity: identity } do
        assert :ok == Mobile.add(identity, "+100")
        assert :ok == Mobile.make_primary(identity, "+100")
        assert { :ok, { :unverified, "+100" } } == Mobile.primary_contact(identity)

        assert :ok == Mobile.add(identity, "+1002")
        assert { :ok, { :unverified, "+100" } } == Mobile.primary_contact(identity)
        assert :ok == Mobile.make_primary(identity, "+1002")
        assert { :ok, { :unverified, "+1002" } } == Mobile.primary_contact(identity)

        assert { :error, "Mobile does not exist" } == Mobile.make_primary(identity, "fake@foo")
        assert { :ok, { :unverified, "+1002" } } == Mobile.primary_contact(identity)

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

        assert { :error, "Mobile does not exist" } == Mobile.make_primary(identity2, "+100")
        assert { :ok, { :unverified, "+1002" } } == Mobile.primary_contact(identity)
    end
end
