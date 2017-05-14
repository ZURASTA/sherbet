defmodule Sherbet.API.Contact.MobileTest do
    use Sherbet.Service.Case

    alias Sherbet.API.Contact.Mobile

    setup do
        { :ok, %{ identity: Ecto.UUID.generate() } }
    end

    test "associate mobile with identity", %{ identity: identity } do
        assert { :ok, false } == Mobile.contact?(identity, "+100")
        assert :ok == Mobile.add(identity, "+100")
        assert { :ok, [{ :unverified, :secondary, "+100" }] } == Mobile.contacts(identity)
        assert { :ok, false } == Mobile.verified?(identity, "+100")
        assert { :ok, true } == Mobile.contact?(identity, "+100")
        assert { :ok, identity } == Mobile.owner("+100")
    end

    test "remove mobile from identity", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.remove(identity, "+100")
        assert { :ok, [] } == Mobile.contacts(identity)
    end

    test "remove unverified mobile per request with valid key", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_removal("+100")

        query = from removal in Sherbet.Service.Contact.Communication.Method.Mobile.RemovalKey.Model,
            join: contact in Sherbet.Service.Contact.Communication.Method.Mobile.Model, on: contact.id == removal.mobile_id and contact.mobile == "+100",
            select: removal.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Mobile.finalise_removal("+100", key)
        assert { :ok, [] } == Mobile.contacts(identity)
    end

    test "verify unverified mobile per request for identity with valid key", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100")

        assert :ok == Mobile.request_verification(identity, "+100")

        query = from verification in Sherbet.Service.Contact.Communication.Method.Mobile.VerificationKey.Model,
            join: contact in Sherbet.Service.Contact.Communication.Method.Mobile.Model, on: contact.id == verification.mobile_id and contact.mobile == "+100",
            select: verification.key

        key = Sherbet.Service.Repo.one!(query)

        assert :ok == Mobile.finalise_verification(identity, "+100", key)
        assert { :ok, [{ :verified, :secondary, "+100" }] } == Mobile.contacts(identity)
        assert { :ok, true } == Mobile.verified?(identity, "+100")
    end

    test "setting mobile priority", %{ identity: identity } do
        :ok = Mobile.add(identity, "+100", :primary)

        assert { :ok, { :unverified, "+100" } } == Mobile.primary_contact(identity)

        assert :ok == Mobile.add(identity, "+1002")
        assert { :ok, { :unverified, "+100" } } == Mobile.primary_contact(identity)
        assert :ok == Mobile.set_priority(identity, "+1002", :primary)
        assert { :ok, { :unverified, "+1002" } } == Mobile.primary_contact(identity)
    end
end
