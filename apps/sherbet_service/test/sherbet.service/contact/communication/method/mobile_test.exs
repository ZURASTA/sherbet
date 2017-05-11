defmodule Sherbet.Service.Contact.Communication.Method.MobileTest do
    use Sherbet.Service.Case

    alias Sherbet.Service.Contact.Communication.Method.Mobile

    test "associate mobile with identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        { :ok, contacts } = Mobile.contacts(identity)
        assert contacts == []

        assert :ok == Mobile.add(identity, "+100")

        { :ok, contacts } = Mobile.contacts(identity)
        assert contacts == [{ :unverified, :secondary, "+100" }]
        assert { :ok, false } == Mobile.verified?(identity, "+100")
    end

    test "associate pre-existing mobile with identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")
        assert { :error, "Failed to add mobile contact" } == Mobile.add(identity, "+100")
    end

    test "remove verified mobile from identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        :ok = Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Mobile.finalise_verification(identity, "+100", key)

        assert :ok == Mobile.remove(identity, "+100")

        { :ok, contacts } = Mobile.contacts(identity)
        assert contacts == []
    end

    test "remove mobile from identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.remove(identity, "+100")

        { :ok, contacts } = Mobile.contacts(identity)
        assert contacts == []
    end

    test "remove non-existing mobile from identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        assert { :error, "Failed to remove the contact" } == Mobile.remove(identity, "+999")
    end

    test "remove unverified mobile per request with valid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_removal("+100")

        query = from removal in Mobile.RemovalKey.Model,
            join: contact in Mobile.Model, on: contact.id == removal.mobile_id and contact.mobile == "+100",
            select: removal.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Mobile.finalise_removal("+100", key)

        { :ok, contacts } = Mobile.contacts(identity)
        assert contacts == []
    end

    test "remove verified mobile per request" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        :ok = Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Mobile.finalise_verification(identity, "+100", key)

        assert { :error, "Mobile is verified" } == Mobile.request_removal("+100")
    end

    test "remove unverified mobile per request with invalid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_removal("+100")
        assert { :error, "Invalid removal attempt" } == Mobile.finalise_removal("+100", "")

        { :ok, contacts } = Mobile.contacts(identity)
        assert contacts == [{ :unverified, :secondary, "+100" }]
    end

    test "remove non-existent mobile per request" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        assert { :error, "Mobile does not exist" } == Mobile.request_removal("+999")
    end

    test "verify unverified mobile per request for identity with valid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Mobile.finalise_verification(identity, "+100", key)

        { :ok, contacts } = Mobile.contacts(identity)
        assert contacts == [{ :verified, :secondary, "+100" }]
        assert { :ok, true } == Mobile.verified?(identity, "+100")
    end

    test "verify verified mobile per request for identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        :ok = Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Mobile.finalise_verification(identity, "+100", key)

        assert { :error, "Mobile is verified" } == Mobile.request_verification(identity, "+100")
    end

    test "verify unverified mobile per request for wrong identity with valid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        { :ok, token } = Gobstopper.API.Auth.Email.register("foo2@bar", "secret")
        identity2 = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_verification(identity, "+100")

        query = from verification in Mobile.VerificationKey.Model,
            join: contact in Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert { :error, "Invalid verification attempt" } == Mobile.finalise_verification(identity2, "+100", key)

        { :ok, contacts } = Mobile.contacts(identity)
        assert contacts == [{ :unverified, :secondary, "+100" }]
        assert { :ok, false } == Mobile.verified?(identity, "+100")
    end

    test "verify unverified mobile per request for identity with invalid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_verification(identity, "+100")
        assert { :error, "Invalid verification attempt" } == Mobile.finalise_verification(identity, "+100", "")

        { :ok, contacts } = Mobile.contacts(identity)
        assert contacts == [{ :unverified, :secondary, "+100" }]
        assert { :ok, false } == Mobile.verified?(identity, "+100")
    end

    test "verify non-existent mobile per request for identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Mobile.add(identity, "+100")

        assert { :error, "Mobile does not exist" } == Mobile.request_verification(identity, "+999")
    end
end
