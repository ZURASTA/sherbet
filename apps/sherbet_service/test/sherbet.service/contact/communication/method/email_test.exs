defmodule Sherbet.Service.Contact.Communication.Method.EmailTest do
    use Sherbet.Service.Case

    alias Sherbet.Service.Contact.Communication.Method.Email

    test "associate email with identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        # { :ok, contacts } = Email.contacts(identity)
        # assert contacts == [{ :unverified, "foo@bar" }]

        assert :ok == Email.add(identity, "foo@foo")

        { :ok, contacts } = Email.contacts(identity)
        assert Enum.sort(contacts) == Enum.sort([{ :unverified, :secondary, "foo@foo" }]) #Enum.sort([{ :unverified, :primary, "foo@bar" }, { :unverified, :secondary, "foo@foo" }])
        assert { :ok, false } == Email.verified?(identity, "foo@foo")
    end

    test "associate pre-existing email with identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")
        assert { :error, "Failed to add email contact" } == Email.add(identity, "foo@foo")
    end

    test "remove verified email from identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        :ok = Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Email.finalise_verification(identity, "foo@foo", key)

        assert :ok == Email.remove(identity, "foo@foo")

        { :ok, contacts } = Email.contacts(identity)
        assert contacts == [] #[{ :unverified, :primary, "foo@bar" }]
    end

    test "remove email from identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.remove(identity, "foo@foo")

        { :ok, contacts } = Email.contacts(identity)
        assert contacts == [] #[{ :unverified, :primary, "foo@bar" }]
    end

    test "remove non-existing email from identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        assert { :error, "Failed to remove the contact" } == Email.remove(identity, "fake@foo")
    end

    test "remove unverified email per request with valid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_removal("foo@foo")

        query = from removal in Email.RemovalKey.Model,
            join: contact in Email.Model, on: contact.id == removal.email_id and contact.email == "foo@foo",
            select: removal.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Email.finalise_removal("foo@foo", key)

        { :ok, contacts } = Email.contacts(identity)
        assert contacts == [] #[{ :unverified, :primary, "foo@bar" }]
    end

    test "remove verified email per request" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        :ok = Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Email.finalise_verification(identity, "foo@foo", key)

        assert { :error, "Email is verified" } == Email.request_removal("foo@foo")
    end

    test "remove unverified email per request with invalid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_removal("foo@foo")
        assert { :error, "Invalid removal attempt" } == Email.finalise_removal("foo@foo", "")

        { :ok, contacts } = Email.contacts(identity)
        assert contacts == [{ :unverified, :secondary, "foo@foo" }] #Enum.sort([{ :unverified, :secondary, "foo@foo" }, { :unverified, :primary, "foo@bar" }])
    end

    test "remove non-existent email per request" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        assert { :error, "Email does not exist" } == Email.request_removal("fake@foo")
    end

    test "verify unverified email per request for identity with valid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Email.finalise_verification(identity, "foo@foo", key)

        { :ok, contacts } = Email.contacts(identity)
        assert contacts == [{ :verified, :secondary, "foo@foo" }] #Enum.sort([{ :verified, :secondary, "foo@foo" }, { :unverified, :primary, "foo@bar" }])
        assert { :ok, true } == Email.verified?(identity, "foo@foo")
    end

    test "verify verified email per request for identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        :ok = Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        :ok = Email.finalise_verification(identity, "foo@foo", key)

        assert { :error, "Email is verified" } == Email.request_verification(identity, "foo@foo")
    end

    test "verify unverified email per request for wrong identity with valid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        { :ok, token } = Gobstopper.API.Auth.Email.register("foo2@bar", "secret")
        identity2 = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_verification(identity, "foo@foo")

        query = from verification in Email.VerificationKey.Model,
            join: contact in Email.Model, on: contact.id == verification.email_id and contact.email == "foo@foo",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert { :error, "Invalid verification attempt" } == Email.finalise_verification(identity2, "foo@foo", key)

        { :ok, contacts } = Email.contacts(identity)
        assert contacts == [{ :unverified, :secondary, "foo@foo" }] #Enum.sort([{ :unverified, :secondary, "foo@foo" }, { :unverified, :primary, "foo@bar" }])
        assert { :ok, false } == Email.verified?(identity, "foo@foo")
    end

    test "verify unverified email per request for identity with invalid key" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        assert :ok == Email.request_verification(identity, "foo@foo")
        assert { :error, "Invalid verification attempt" } == Email.finalise_verification(identity, "foo@foo", "")

        { :ok, contacts } = Email.contacts(identity)
        assert contacts == [{ :unverified, :secondary, "foo@foo" }] #Enum.sort([{ :unverified, :secondary, "foo@foo" }, { :unverified, :primary, "foo@bar" }])
        assert { :ok, false } == Email.verified?(identity, "foo@foo")
    end

    test "verify non-existent email per request for identity" do
        { :ok, token } = Gobstopper.API.Auth.Email.register("foo@bar", "secret")
        identity = Gobstopper.API.Auth.verify(token)

        :ok = Email.add(identity, "foo@foo")

        assert { :error, "Email does not exist" } == Email.request_verification(identity, "fake@foo")
    end
end
