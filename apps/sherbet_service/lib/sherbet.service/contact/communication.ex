defmodule Sherbet.Service.Contact.Communication do
    @moduledoc """
      Provides interfaces to communications.
    """

    import Ecto.Query
    require Logger
    alias Sherbet.Service.Contact.Communication
    alias Gobstopper.API.Auth


    @doc """
      Add a communication type to be associated with the given identity.

      Returns `:ok` on successful addition. Otherwise returns a error.
    """
    @spec add(atom, String.t, Auth.uuid) :: :ok | { :error, String.t }
    def add(type, communication, identity) do
        Communication.Method.add(type, identity, communication)
    end

    @doc """
      Add a communication type to be associated with the given identity. And set its
      priority.

      Returns `:ok` on successful addition. Otherwise returns a error.
    """
    @spec add(atom, String.t, :secondary | :primary, Auth.uuid) :: :ok | { :error, String.t }
    def add(type, communication, :secondary, identity), do: add(type, communication, identity)
    def add(type, communication, :primary, identity) do
        case Communication.Method.add(type, identity, communication) do
            :ok -> Communication.Method.make_primary(type, identity, communication)
            error -> error
        end
    end

    @doc """
      Remove a communication type from a given identity.

      Returns `:ok` on successful removal. Otherwise returns an error.
    """
    @spec remove(atom, String.t, Auth.uuid) :: :ok | { :error, String.t }
    def remove(type, communication, identity) do
        Communication.Method.remove(type, identity, communication)
    end

    @doc """
      Change a communication type associated with the identity to become a primary
      communication for that method.

      Will turn any other primary communication of that type for that identity into a
      secondary communication option.

      Returns `:ok` on successful change. Otherwise returns an error.
    """
    @spec make_primary(atom, String.t, Auth.uuid) :: :ok | { :error, String.t }
    def make_primary(type, communication, identity) do
        Communication.Method.make_primary(type, identity, communication)
    end

    @doc """
      Request a communication type associated with another identity, be removed.

      Removal requests only apply to unverified communications.

      Returns `:ok` if request was successful. Otherwise returns an error.
    """
    @spec request_removal(atom, String.t) :: :ok | { :error, String.t }
    def request_removal(type, communication) do
        Communication.Method.request_removal(type, communication)
    end

    @doc """
      Finalise the request that a communication type be removed.

      If the communication is verified, then it should return an error.

      Returns `:ok` if removal was successful. Otherwise returns an error.
    """
    @spec finalise_removal(atom, String.t, String.t) :: :ok | { :error, String.t }
    def finalise_removal(type, communication, key) do
        Communication.Method.finalise_removal(type, communication, key)
    end

    @doc """
      Check if a communication type belonging to the given identity has been verified.

      Returns `{ :ok, verified }` if the operation was successful, where `verified`
      is whether the email was verified (`true`) or not (`false`). Otherwise returns
      an error.
    """
    @spec verified?(atom, String.t, Auth.uuid) :: { :ok, boolean } | { :error, String.t }
    def verified?(type, communication, identity) do
        Communication.Method.verified?(type, identity, communication)
    end

    @doc """
      Request a comunication type be verified.

      If the comunication is already verified, then it should return an error.

      Returns `:ok` if request was successful. Otherwise returns an error.
    """
    @spec request_verification(atom, String.t, Auth.uuid) :: :ok | { :error, String.t }
    def request_verification(type, communication, identity) do
        Communication.Method.request_verification(type, identity, communication)
    end

    @doc """
      Finalise the verification request for a communication type.

      If the communication is already verified, then it should return an error.

      Returns `:ok` if verification was successful. Otherwise returns an error.
    """
    @spec finalise_verification(atom, String.t, String.t, Auth.uuid) :: :ok | { :error, String.t }
    def finalise_verification(type, communication, key, identity) do
        Communication.Method.finalise_verification(type, identity, communication, key)
    end

    @doc """
      Get a list of communications of type associated with the given identity.

      Returns `{ :ok, contacts }` if the operation was successful, where `contacts` is
      the list of communication methods associated with the given identity and their
      current verification status and priority. Otherwise returns the reason of failure.
    """
    @spec contacts(atom, Auth.uuid) :: { :ok, [{ :unverified | :verified, :secondary | :primary, String.t }] } | { :error, String.t }
    def contacts(type, identity) do
        Communication.Method.contacts(type, identity)
    end

    @doc """
      Get the primary communication of type associated with the given identity.

      Returns `{ :ok, contact }` if the operation was successful, where `contact` is
      the primary communication method associated with the given identity and its
      current verification status. Otherwise returns the reason of failure.
    """
    @spec primary_contact(atom, Auth.uuid) :: { :ok, { :unverified | :verified, String.t } } | { :error, String.t }
    def primary_contact(type, identity) do
        Communication.Method.primary_contact(type, identity)
    end
end
