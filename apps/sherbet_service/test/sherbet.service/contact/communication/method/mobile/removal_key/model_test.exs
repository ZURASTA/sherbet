defmodule Sherbet.Service.Contact.Communication.Method.Mobile.RemovalKey.ModelTest do
    use Sherbet.Service.Case

    alias Sherbet.Service.Contact.Communication.Method.Mobile.RemovalKey

    @valid_model %RemovalKey.Model{
        mobile_id: 1,
        key: "test"
    }

    test "empty" do
        refute_change(%RemovalKey.Model{}, %{})
    end

    test "only mobile_id" do
        refute_change(%RemovalKey.Model{}, %{ mobile_id: @valid_model.mobile_id })
    end

    test "only key" do
        refute_change(%RemovalKey.Model{}, %{ key: @valid_model.key })
    end

    test "without mobile_id" do
        refute_change(@valid_model, %{ mobile_id: nil })
    end

    test "without key" do
        refute_change(@valid_model, %{ key: nil })
    end

    test "valid model" do
        assert_change(@valid_model, %{})
    end

    test "duplicates" do
        mobile = Sherbet.Service.Repo.insert!(Sherbet.Service.Contact.Communication.Method.Mobile.Model.insert_changeset(%Sherbet.Service.Contact.Communication.Method.Mobile.Model{}, %{ identity: Ecto.UUID.generate(), mobile: "+123" }))
        removal = Sherbet.Service.Repo.insert!(RemovalKey.Model.changeset(%RemovalKey.Model{}, %{ mobile_id: mobile.id, key: "test" }))

        assert_change(%RemovalKey.Model{}, %{ mobile_id: removal.mobile_id, key: removal.key })
        |> assert_insert(:ok)
    end

    test "deletion" do
        mobile = Sherbet.Service.Repo.insert!(Sherbet.Service.Contact.Communication.Method.Mobile.Model.insert_changeset(%Sherbet.Service.Contact.Communication.Method.Mobile.Model{}, %{ identity: Ecto.UUID.generate(), mobile: "+123" }))
        removal = Sherbet.Service.Repo.insert!(RemovalKey.Model.changeset(%RemovalKey.Model{}, %{ mobile_id: mobile.id, key: "test" }))

        Sherbet.Service.Repo.delete!(mobile)
        assert nil == Sherbet.Service.Repo.get(RemovalKey.Model, removal.id)
    end
end
