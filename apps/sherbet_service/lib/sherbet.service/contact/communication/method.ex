defmodule Sherbet.Service.Contact.Communication.Method do
    @moduledoc """
      Manages the interactions with communication methods.

      Communication implementations will implement the given callbacks to handle the
      specific communication method.

      ##Implementing a communication method

      Communication should be implemented in a module conforming to
      `#{String.slice(to_string(__MODULE__), 7..-1)}.method`. Where type is the capitalized
      communication method.

      e.g. For a communication that should be identified using the :email atom, then the
      implementation for that communication method should fall under
      `#{String.slice(to_string(__MODULE__), 7..-1)}.Email`.
    """

    alias Gobstopper.API.Auth

    @doc """
      Implement the behaviour for adding a new communication method and associating it with
      the given identity.

      If the contact is already in use, it will return an error.

      If the operation was successful return `:ok`.
    """
    @callback add(identity :: Auth.uuid, contact :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for removing a communication method associated with the
      given identity.

      If the operation was successful return `:ok`. Otherwise return the error.
    """
    @callback remove(identity :: Auth.uuid, contact :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for requesting an unverified communication method be removed.
      This should generate the unique key that will be sent to the contact, that the
      requester will require in order to finalise the removal.

      If the communication method has been verified, then it should return an error.

      If the operation was successful return `:ok`.
    """
    @callback request_removal(contact :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for finalising a removal request of an unverified
      communication method.

      If the communication method has been verified, then it should return an error.

      If the operation was successful return `:ok`.
    """
    @callback finalise_removal(contact :: String.t, key :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for identifying if a communicaton method belonging to the given
      identity has been verified.

      If the operation was successful return whether it was verified or not (true if it was
      verified, otherwise false). Otherwise return an error.
    """
    @callback verified?(identity :: Auth.uuid, contact :: String.t) :: { :ok, verified :: boolean } | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for requesting an unverified communication method be verified.
      This should generate the unique key that will be sent to the contact, that the
      requester will require in order to finalise the verification of that contact.

      If the communication method has already been verified, then it should return an error.

      If the operation was successful return `:ok`. Otherwise return an error.
    """
    @callback request_verification(identity :: Auth.uuid, contact :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for finalising a verification request of an unverified
      communication method.

      If the communication method has already been verified, then it should return an error.

      If the operation was successful return `:ok`. Otherwise return an error.
    """
    @callback finalise_verification(identity :: Auth.uuid, contact :: String.t, key :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for retrieving the contacts of the communication method for
      the given identity.

      If the operation was successful return `{ :ok, contacts }`, where `contacts` is
      the list of communication methods associated with the given identity and their
      current verification status and priority. Otherwise return an error.
    """
    @callback contacts(identity :: Auth.uuid) :: { :ok, contacts :: [{ :unverified | :verified, :secondary | :primary, String.t }] } | { :error, reason :: String.t }

    @doc """
      Associate a new contact with the given identity.

      If the contact is already in use, it will return an error.

      If the operation was successful return `:ok`.
    """
    @spec add(atom, Auth.uuid, String.t) :: :ok | { :error, String.t }
    def add(type, identity, contact) do
        atom_to_module(type).add(identity, contact)
    end

    @doc """
      Remove the contact associated with the identity.

      Returns `:ok` if the operation was successful, otherwise returns an error.
    """
    @spec remove(atom, Auth.uuid, String.t) :: :ok | { :error, String.t }
    def remove(type, identity, contact) do
        atom_to_module(type).remove(identity, contact)
    end

    @doc """
      Request a contact be removed.

      If the contact is verified, then it should return an error.

      If the operation was successful return `:ok`.
    """
    @spec request_removal(atom, String.t) :: :ok | { :error, String.t }
    def request_removal(type, contact) do
        atom_to_module(type).request_removal(contact)
    end

    @doc """
      Finalise the request that a contact be removed.

      If the contact is verified, then it should return an error.

      If the operation was successful return `:ok`.
    """
    @spec finalise_removal(atom, String.t, String.t) :: :ok | { :error, String.t }
    def finalise_removal(type, contact, key) do
        atom_to_module(type).finalise_removal(contact, key)
    end

    @doc """
      Check if a contact belonging to the given identity has been verified.

      Returns true if it is verified, otherwise false.
    """
    @spec verified?(atom, Auth.uuid, String.t) :: { :ok, boolean } | { :error, String.t }
    def verified?(type, identity, contact) do
        atom_to_module(type).verified?(identity, contact)
    end

    @doc """
    Request a contact be verified.

    If the contact is already verified, then it should return an error.

    If the operation was successful return `:ok`.
    """
    @spec request_verification(atom, Auth.uuid, String.t) :: :ok | { :error, String.t }
    def request_verification(type, identity, contact) do
        atom_to_module(type).request_verification(identity, contact)
    end

    @doc """
      Finalise the verification request for a contact.

      If the contact is already verified, then it should return an error.

      If the operation was successful return `:ok`.
    """
    @spec finalise_verification(atom, Auth.uuid, String.t, String.t) :: :ok | { :error, String.t }
    def finalise_verification(type, identity, contact, key) do
        atom_to_module(type).finalise_verification(identity, contact, key)
    end

    @doc """
      Get a list of contacts associated with the given identity.

      If the operation was successful return `{ :ok, contacts }`, where `contacts` is
      the list of communication methods associated with the given identity and their
      current verification status and priority. Otherwise returns the reason of failure.
    """
    @spec contacts(atom, Auth.uuid) :: { :ok, [{ :unverified | :verified, :secondary | :primary, String.t }] } | { :error, String.t }
    def contacts(type, identity) do
        atom_to_module(type).contacts(identity)
    end

    @spec atom_to_module(atom) :: atom
    defp atom_to_module(name) do
        String.to_atom(to_string(__MODULE__) <> "." <> format_as_module(to_string(name)))
    end

    @spec format_as_module(String.t) :: String.t
    defp format_as_module(name) do
        name
        |> String.split(".")
        |> Enum.map(fn module ->
            String.split(module, "_") |> Enum.map(&String.capitalize(&1)) |> Enum.join
        end)
        |> Enum.join(".")
    end
end
