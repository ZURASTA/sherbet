defmodule Sherbet.Service.Contact.Communication.PrimaryContact.Model do
    use Ecto.Schema
    import Ecto
    import Ecto.Changeset
    import Protecto
    @moduledoc """
      A model representing the primary contacts.

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

    schema "primary_contacts" do
        field :identity, Ecto.UUID
        belongs_to :email, Sherbet.Service.Contact.Communication.Method.Email.Model
        belongs_to :mobile, Sherbet.Service.Contact.Communication.Method.Mobile.Model
        timestamps()
    end

    @doc """
      Builds a changeset for insertion based on the `struct` and `params`.

      Enforces:
      * `identity` field is required
      * `identity` field is unique
      * `email_id` field is unique
      * `mobile_id` field is unique
      * `email_id` field is associated with an entry in `Sherbet.Service.Contact.Communication.Method.Email.Model`
      * `mobile_id` field is associated with an entry in `Sherbet.Service.Contact.Communication.Method.Mobile.Model`
    """
    def insert_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity, :email_id, :mobile_id])
        |> validate_required([:identity])
        |> unique_constraint(:identity)
        |> unique_constraint(:email_id)
        |> unique_constraint(:mobile_id)
        |> assoc_constraint(:email)
        |> assoc_constraint(:mobile)
    end

    @doc """
      Builds a changeset for update based on the `struct` and `params`.

      Enforces:
      * `identity` field is not empty
      * `identity` field is unique
      * `email_id` field is unique
      * `mobile_id` field is unique
      * `email_id` field is associated with an entry in `Sherbet.Service.Contact.Communication.Method.Email.Model`
      * `mobile_id` field is associated with an entry in `Sherbet.Service.Contact.Communication.Method.Mobile.Model`
    """
    def update_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity, :mobile_, :verified])
        |> validate_emptiness(:identity)
        |> unique_constraint(:identity)
        |> unique_constraint(:email_id)
        |> unique_constraint(:mobile_id)
        |> assoc_constraint(:email)
        |> assoc_constraint(:mobile)
    end
end
