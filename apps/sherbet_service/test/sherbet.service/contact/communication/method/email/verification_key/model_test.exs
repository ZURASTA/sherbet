defmodule Sherbet.Service.Contact.Communication.Method.Email.VerificationKey.ModelTest do
    use Sherbet.Service.Case

    alias Sherbet.Service.Contact.Communication.Method.Email.VerificationKey

    @valid_model %VerificationKey.Model{
        email_id: 1,
        key: "test"
    }

    test "empty" do
        refute_change(%VerificationKey.Model{}, %{})
    end

    test "only email_id" do
        refute_change(%VerificationKey.Model{}, %{ email_id: @valid_model.email_id })
    end

    test "only key" do
        refute_change(%VerificationKey.Model{}, %{ key: @valid_model.key })
    end

    test "without email_id" do
        refute_change(@valid_model, %{ email_id: nil })
    end

    test "without key" do
        refute_change(@valid_model, %{ key: nil })
    end

    test "valid model" do
        assert_change(@valid_model, %{})
    end

    test "duplicates" do
        email = Sherbet.Service.Repo.insert!(Sherbet.Service.Contact.Communication.Method.Email.Model.insert_changeset(%Sherbet.Service.Contact.Communication.Method.Email.Model{}, %{ identity: Ecto.UUID.generate(), email: "foo@bar" }))
        verification = Sherbet.Service.Repo.insert!(VerificationKey.Model.changeset(%VerificationKey.Model{}, %{ email_id: email.id, key: "test" }))

        assert_change(%VerificationKey.Model{}, %{ email_id: verification.email_id, key: verification.key })
        |> assert_insert(:ok)
    end
end
