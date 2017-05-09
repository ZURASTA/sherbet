defmodule Sherbet.Service.Contact.Communication.Method.Mobile.RemovalKey.Model do
    use Ecto.Schema
    import Ecto
    import Ecto.Changeset
    import Protecto
    @moduledoc """
      A model representing the different mobile removal keys.

      ##Fields

      ###:id
      Is the unique reference to the removal key entry. Is an `integer`.

      ###:mobile_id
      Is the reference to the mobile the removal key belongs to. Is an
      `integer` to `Sherbet.Service.Contact.Communication.Method.Mobile.Model`.

      ###:key
      Is the removal key needed to verify this entry. Is a `string`.
    """

    schema "mobile_removal_keys" do
        belongs_to :mobile, Sherbet.Service.Contact.Communication.Method.Mobile.Model
        field :key, :string
        timestamps()
    end

    @doc """
      Builds a changeset for the `struct` and `params`.

      Enforces:
      * `mobile_id` field is required
      * `key` field is required
      * `mobile_id` field is associated with an entry in `Sherbet.Service.Contact.Communication.Method.Mobile.Model`
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:mobile_id, :key])
        |> validate_required([:mobile_id, :key])
        |> assoc_constraint(:mobile)
    end
end
