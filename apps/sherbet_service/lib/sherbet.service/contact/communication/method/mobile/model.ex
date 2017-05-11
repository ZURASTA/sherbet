defmodule Sherbet.Service.Contact.Communication.Method.Mobile.Model do
    use Ecto.Schema
    import Ecto
    import Ecto.Changeset
    import Protecto
    @moduledoc """
      A model representing the different mobile contacts.

      ##Fields

      ###:id
      Is the unique reference to the mobile contact entry. Is an `integer`.

      ###:identity
      Is the identity the mobile contact belongs to. Is an `UUID`.

      ###:mobile
      Is the mobile part of the contact. Is a `string`.

      ###:verified
      Indicates whether the mobile has been verified to belong to the given
      identity. Is a `boolean`.

      ###:primary
      Indicates whether the mobile is the primary mobile to be used. Is a `boolean`.
    """

    schema "mobiles" do
        field :identity, Ecto.UUID
        field :mobile, :string
        field :verified, :boolean
        field :primary, :boolean
        timestamps()
    end

    @doc """
      Builds a changeset for insertion based on the `struct` and `params`.

      Enforces:
      * `identity` field is required
      * `mobile` field is required
      * `mobile` field is a valid mobile
      * `mobile` field is unique
      * checks uniqueness of primary contact (one per unique identity)
    """
    def insert_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity, :mobile, :verified, :primary])
        |> validate_required([:identity, :mobile])
        |> validate_phone_number(:mobile)
        |> unique_constraint(:mobile)
        |> unique_constraint(:primary_contact)
    end

    @doc """
      Builds a changeset for update based on the `struct` and `params`.

      Enforces:
      * `identity` field is not empty
      * `mobile` field is not empty
      * `verified` field is not empty
      * `mobile` field is a valid phone number
      * `mobile` field is unique
      * checks uniqueness of primary contact (one per unique identity)
    """
    def update_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity, :mobile, :verified, :primary])
        |> validate_emptiness(:identity)
        |> validate_emptiness(:mobile)
        |> validate_emptiness(:verified)
        |> validate_phone_number(:mobile)
        |> unique_constraint(:mobile)
        |> unique_constraint(:primary_contact)
    end
end
