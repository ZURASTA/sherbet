defmodule Sherbet.Service.Contact.Communication.Method.Email.ModelTest do
    use Sherbet.Service.Case

    alias Sherbet.Service.Contact.Communication.Method.Email

    @valid_model %Email.Model{
        identity: Ecto.UUID.generate(),
        email: "foo@test",
        verified: true,
        primary: false
    }

    test "empty" do
        refute_change(%Email.Model{}, %{}, :insert_changeset)
    end

    test "only identity" do
        refute_change(%Email.Model{}, %{ identity: @valid_model.identity }, :insert_changeset)

        assert_change(@valid_model, %{ identity: Ecto.UUID.generate() }, :update_changeset)
    end

    test "only email" do
        refute_change(%Email.Model{}, %{ email: @valid_model.email }, :insert_changeset)

        assert_change(@valid_model, %{ email: "foo@bar" }, :update_changeset)
    end

    test "only verified" do
        refute_change(%Email.Model{}, %{ verified: @valid_model.verified }, :insert_changeset)

        assert_change(@valid_model, %{ verified: false }, :update_changeset)
    end

    test "only primary" do
        refute_change(%Email.Model{}, %{ primary: @valid_model.primary }, :insert_changeset)

        assert_change(@valid_model, %{ primary: false }, :update_changeset)
    end

    test "without identity" do
        refute_change(@valid_model, %{ identity: nil }, :insert_changeset)
    end

    test "without email" do
        refute_change(@valid_model, %{ email: nil }, :insert_changeset)
    end

    test "without verified" do
        assert_change(@valid_model, %{ verified: nil }, :insert_changeset)
    end

    test "without primary" do
        assert_change(@valid_model, %{ primary: nil }, :insert_changeset)
    end

    test "valid model" do
        assert_change(@valid_model, %{}, :insert_changeset)

        assert_change(@valid_model, %{}, :update_changeset)
    end

    test "email formatting" do
        refute_change(@valid_model, %{ email: "test" }, :insert_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "@" }, :insert_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "test@" }, :insert_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "test" }, :update_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "@" }, :update_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "test@" }, :update_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })
    end

    test "uniqueness" do
        _email = Sherbet.Service.Repo.insert!(@valid_model)

        assert_change(@valid_model, %{ identity: Ecto.UUID.generate(), email: @valid_model.email }, :insert_changeset)
        |> assert_insert(:error)
        |> assert_error_value(:email, { "has already been taken", [] })

        assert_change(@valid_model, %{ identity: Ecto.UUID.generate(), email: "foo@bar" }, :insert_changeset)
        |> assert_insert(:ok)

        assert_change(@valid_model, %{ identity: @valid_model.identity, email: "foo@foo" }, :insert_changeset)
        |> assert_insert(:ok)
    end

    test "primary uniqueness" do
        _email = Sherbet.Service.Repo.insert!(Email.Model.insert_changeset(@valid_model, %{ primary: true }))

        assert_change(@valid_model, %{ identity:  @valid_model.identity, email: "foo@bar", primary: true }, :insert_changeset)
        |> assert_insert(:error)
        |> assert_error_value(:primary_contact, { "has already been taken", [] })

        assert_change(@valid_model, %{ identity: Ecto.UUID.generate(), email: "foo@bar", primary: true }, :insert_changeset)
        |> assert_insert(:ok)

        assert_change(@valid_model, %{ identity: @valid_model.identity, email: "foo@foo", primary: false }, :insert_changeset)
        |> assert_insert(:ok)
    end
end
