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
    """

    schema "mobiles" do
        field :identity, Ecto.UUID
        field :mobile, :string
        field :verified, :boolean
        timestamps()
    end

    @doc """
      Builds a changeset for insertion based on the `struct` and `params`.

      Enforces:
      * `identity` field is required
      * `mobile` field is required
      * `mobile` field is a valid mobile
      * `mobile` field is unique
    """
    def insert_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity, :mobile, :verified])
        |> validate_required([:identity, :mobile])
        |> validate_phone_number(:mobile)
        |> unique_constraint(:mobile)
    end

    @doc """
      Builds a changeset for update based on the `struct` and `params`.

      Enforces:
      * `identity` field is not empty
      * `mobile` field is not empty
      * `verified` field is not empty
      * `mobile` field is a valid phone number
      * `mobile` field is unique
    """
    def update_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity, :mobile, :verified])
        |> validate_emptiness(:identity)
        |> validate_emptiness(:mobile)
        |> validate_emptiness(:verified)
        |> validate_phone_number(:mobile)
        |> unique_constraint(:mobile)
    end
end
