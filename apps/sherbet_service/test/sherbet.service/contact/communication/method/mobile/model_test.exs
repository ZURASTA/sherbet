defmodule Sherbet.Service.Contact.Communication.Method.Mobile.ModelTest do
    use Sherbet.Service.Case

    alias Sherbet.Service.Contact.Communication.Method.Mobile

    @valid_model %Mobile.Model{
        identity: Ecto.UUID.generate(),
        mobile: "+123",
        verified: true
    }

    test "empty" do
        refute_change(%Mobile.Model{}, %{}, :insert_changeset)
    end

    test "only identity" do
        refute_change(%Mobile.Model{}, %{ identity: @valid_model.identity }, :insert_changeset)

        assert_change(@valid_model, %{ identity: Ecto.UUID.generate() }, :update_changeset)
    end

    test "only mobile" do
        refute_change(%Mobile.Model{}, %{ mobile: @valid_model.mobile }, :insert_changeset)

        assert_change(@valid_model, %{ mobile: "+100" }, :update_changeset)
    end

    test "only verified" do
        refute_change(%Mobile.Model{}, %{ verified: @valid_model.verified }, :insert_changeset)

        assert_change(@valid_model, %{ verified: false }, :update_changeset)
    end

    test "without identity" do
        refute_change(@valid_model, %{ identity: nil }, :insert_changeset)
    end

    test "without mobile" do
        refute_change(@valid_model, %{ mobile: nil }, :insert_changeset)
    end

    test "without verified" do
        assert_change(@valid_model, %{ verified: nil }, :insert_changeset)
    end

    test "valid model" do
        assert_change(@valid_model, %{}, :insert_changeset)

        assert_change(@valid_model, %{}, :update_changeset)
    end

    test "mobile formatting" do
        refute_change(@valid_model, %{ mobile: "123" }, :insert_changeset)
        |> assert_error_value(:mobile, { "should begin with a country prefix", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+123a" }, :insert_changeset)
        |> assert_error_value(:mobile, { "should contain the country prefix followed by only digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+" }, :insert_changeset)
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+1234567890123456789" }, :insert_changeset)
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "123" }, :update_changeset)
        |> assert_error_value(:mobile, { "should begin with a country prefix", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+123a" }, :update_changeset)
        |> assert_error_value(:mobile, { "should contain the country prefix followed by only digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+" }, :update_changeset)
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+1234567890123456789" }, :update_changeset)
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })
    end

    test "uniqueness" do
        mobile = Sherbet.Service.Repo.insert!(@valid_model)

        assert_change(@valid_model, %{ identity: Ecto.UUID.generate(), mobile: @valid_model.mobile }, :insert_changeset)
        |> assert_insert(:error)
        |> assert_error_value(:mobile, { "has already been taken", [] })

        assert_change(@valid_model, %{ identity: Ecto.UUID.generate(), mobile: "+100" }, :insert_changeset)
        |> assert_insert(:ok)

        assert_change(@valid_model, %{ identity: @valid_model.identity, mobile: "+200" }, :insert_changeset)
        |> assert_insert(:ok)
    end
end
