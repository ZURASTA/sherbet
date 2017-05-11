defmodule Sherbet.Service.Contact.Communication.Method.Email.Model do
    use Ecto.Schema
    import Ecto
    import Ecto.Changeset
    import Protecto
    @moduledoc """
      A model representing the different email contacts.

      ##Fields

      ###:id
      Is the unique reference to the email contact entry. Is an `integer`.

      ###:identity
      Is the identity the email contact belongs to. Is an `UUID`.

      ###:email
      Is the email part of the contact. Is a `string`.

      ###:verified
      Indicates whether the email has been verified to belong to the given
      identity. Is a `boolean`.

      ###:primary
      Indicates whether the email is the primary email to be used. Is a `boolean`.
    """

    schema "emails" do
        field :identity, Ecto.UUID
        field :email, :string
        field :verified, :boolean
        field :primary, :boolean
        timestamps()
    end

    @doc """
      Builds a changeset for insertion based on the `struct` and `params`.

      Enforces:
      * `identity` field is required
      * `email` field is required
      * `email` field is a valid email
      * `email` field is unique
      * `primary_contact` field is
      * checks uniqueness of primary contact (one per unique identity)
    """
    def insert_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity, :email, :verified, :primary])
        |> validate_required([:identity, :email])
        |> validate_email(:email)
        |> unique_constraint(:email)
        |> unique_constraint(:primary_contact)
    end

    @doc """
      Builds a changeset for update based on the `struct` and `params`.

      Enforces:
      * `identity` field is not empty
      * `email` field is not empty
      * `verified` field is not empty
      * `email` field is a valid email
      * `email` field is unique
      * checks uniqueness of primary contact (one per unique identity)
    """
    def update_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:identity, :email, :verified, :primary])
        |> validate_emptiness(:identity)
        |> validate_emptiness(:email)
        |> validate_emptiness(:verified)
        |> validate_email(:email)
        |> unique_constraint(:email)
        |> unique_constraint(:primary_contact)
    end
end
