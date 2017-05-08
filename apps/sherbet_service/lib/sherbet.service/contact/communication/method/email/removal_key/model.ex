defmodule Sherbet.Service.Contact.Communication.Method.Email.RemovalKey.Model do
    use Ecto.Schema
    import Ecto
    import Ecto.Changeset
    import Protecto
    @moduledoc """
      A model representing the different email removal keys.

      ##Fields

      ###:id
      Is the unique reference to the removal key entry. Is an `integer`.

      ###:email_id
      Is the reference to the email the removal key belongs to. Is an
      `integer` to `Sherbet.Service.Contact.Communication.Method.Email.Model`.

      ###:key
      Is the removal key needed to verify this entry. Is a `string`.
    """

    schema "email_removal_keys" do
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
