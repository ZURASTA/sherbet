defmodule Sherbet.Service.Contact.Communication.Method.Email.VerificationKey.Model do
    use Ecto.Schema
    import Ecto
    import Ecto.Changeset
    import Protecto
    @moduledoc """
      A model representing the different email verification keys.

      ##Fields

      ###:id
      Is the unique reference to the email contact entry. Is an `integer`.

      ###:email_id
      Is the reference to the email the verification key belongs to. Is an
      `integer` to `Sherbet.Service.Contact.Communication.Method.Email.Model`.

      ###:key
      Is the verification key needed to verify this entry. Is a `string`.
    """

    schema "emails" do
        belongs_to :email, Sherbet.Service.Contact.Communication.Method.Email.Model
        field :key, :string
        timestamps()
    end

    @doc """
      Builds a changeset for the `struct` and `params`.

      Enforces:
      * `email_id` field is required
      * `key` field is required
      * `email_id` field is associated with an entry in `Sherbet.Service.Contact.Communication.Method.Email.Model`
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:email_id, :key])
        |> validate_required([:email_id, :key])
        |> assoc_constraint(:email)
    end
end
