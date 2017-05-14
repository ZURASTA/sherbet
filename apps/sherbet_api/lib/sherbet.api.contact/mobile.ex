defmodule Sherbet.API.Contact.Mobile do
    @moduledoc """
      Handles the management of mobile contacts.
    """

    @type uuid :: String.t

    @service Sherbet.Service.Contact
    @credential_type :mobile

    @doc """
      Associate an mobile with the given identity.

      Returns `:ok` on successful addition. Otherwise returns a error.
    """
    @spec add(uuid, String.t) :: :ok | { :error, String.t }
    def add(identity, mobile) do
        GenServer.call(@service, { :add, { @credential_type, mobile }, identity })
    end

    @doc """
      Associate an mobile with the given identity, and specify its priority.

      Returns `:ok` on successful addition. Otherwise returns a error.
    """
    @spec add(uuid, String.t, :secondary | :primary) :: :ok | { :error, String.t }
    def add(identity, mobile, priority) do
        GenServer.call(@service, { :add, { @credential_type, mobile, priority }, identity })
    end

    @doc """
      Remove an mobile that was associated with the given identity.

      Returns `:ok` on successful removal. Otherwise returns an error.
    """
    @spec remove(uuid, String.t) :: :ok | { :error, String.t }
    def remove(identity, mobile) do
        GenServer.call(@service, { :remove, { @credential_type, mobile }, identity })
    end

    @doc """
      Set an mobile associated with the identity's priority.

      Will turn any other primary mobile contact for that identity into a secondary
      option.

      Returns `:ok` on successful change. Otherwise returns an error.
    """
    @spec set_priority(uuid, String.t, :secondary | :primary) :: :ok | { :error, String.t }
    def set_priority(identity, mobile, priority) do
        GenServer.call(@service, { :set_priority, { @credential_type, mobile, priority }, identity })
    end

    @doc """
      Request an mobile associated with another identity, be removed.

      Removal requests only apply to unverified mobiles.

      Returns `:ok` if request was successful. Otherwise returns an error.
    """
    @spec request_removal(String.t) :: :ok | { :error, String.t }
    def request_removal(mobile) do
        GenServer.call(@service, { :request_removal, { @credential_type, mobile } })
    end

    @doc """
      Finalise the request that an mobile be removed.

      Returns `:ok` if removal was successful. Otherwise returns an error.
    """
    @spec finalise_removal(String.t, String.t) :: :ok | { :error, String.t }
    def finalise_removal(mobile, key) do
        GenServer.call(@service, { :finalise_removal, { @credential_type, mobile, key } })
    end

    @doc """
      Check if an mobile belonging to the given identity has been verified.

      Returns `{ :ok, verified }` if the operation was successful, where `verified`
      is whether the mobile was verified (`true`) or not (`false`). Otherwise returns
      an error.
    """
    @spec verified?(uuid, String.t) :: { :ok, boolean } | { :error, String.t }
    def verified?(identity, mobile) do
        GenServer.call(@service, { :verified?, { @credential_type, mobile }, identity })
    end

    @doc """
      Request an mobile be verified.

      Verification requests only apply to unverified mobiles.

      Returns `:ok` if request was successful. Otherwise returns an error.
    """
    @spec request_verification(uuid, String.t) :: :ok | { :error, String.t }
    def request_verification(identity, mobile) do
        GenServer.call(@service, { :request_verification, { @credential_type, mobile }, identity })
    end

    @doc """
      Finalise the verification request for an mobile.

      Returns `:ok` if verification was successful. Otherwise returns an error.
    """
    @spec finalise_verification(uuid, String.t, String.t) :: :ok | { :error, String.t }
    def finalise_verification(identity, mobile, key) do
        GenServer.call(@service, { :finalise_verification, { @credential_type, mobile, key }, identity })
    end

    @doc """
      Check if an mobile belongs to the given identity.

      Returns `{ :ok, belongs }` if the operation was successful, where `belongs`
      is whether the mobile belongs to the identity (`true`) or not (`false`). Otherwise
      returns an error.
    """
    @spec contact?(uuid, String.t) :: { :ok, boolean } | { :error, String.t }
    def contact?(identity, mobile) do
        case verified?(identity, mobile) do
            { :ok, _ } -> { :ok, true }
            { :error, _ } -> { :ok, false }
        end
    end

    @doc """
      Get a list of mobiles associated with the given identity.

      Returns `{ :ok, contacts }` if the operation was successful, where `contacts` is
      the list of mobiles associated with the given identity and their current verification
      status and priority. Otherwise returns the reason of failure.
    """
    @spec contacts(uuid) :: { :ok, [{ :unverified | :verified, :secondary | :primary, String.t }] } | { :error, String.t }
    def contacts(identity) do
        GenServer.call(@service, { :contacts, { @credential_type }, identity })
    end

    @doc """
      Get the primary mobile associated with the given identity.

      Returns `{ :ok, contact }` if the operation was successful, where `contact` is
      the primary mobile associated with the given identity and its current verification
      status. Otherwise returns the reason of failure.
    """
    @spec primary_contact(uuid) :: { :ok, { :unverified | :verified, String.t } } | { :error, String.t }
    def primary_contact(identity) do
        GenServer.call(@service, { :primary_contact, { @credential_type }, identity })
    end

    @doc """
      Get the owning identity for the specific mobile.

      Returns `{ :ok, identity }` if the operation was successful. Otherwise returns
      the reason of failure.
    """
    @spec owner(String.t) :: { :ok, uuid } | { :error, String.t }
    def owner(mobile) do
        GenServer.call(@service, { :owner, { @credential_type, mobile } })
    end
end
