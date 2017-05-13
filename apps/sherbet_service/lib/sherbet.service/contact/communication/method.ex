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

    @type uuid :: String.t

    @doc """
      Implement the behaviour for adding a new communication method and associating it with
      the given identity.

      If the contact is already in use, it will return an error.

      If the operation was successful return `:ok`.
    """
    @callback add(identity :: uuid, contact :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for removing a communication method associated with the
      given identity.

      If the operation was successful return `:ok`. Otherwise return the error.
    """
    @callback remove(identity :: uuid, contact :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for setting a communication method associated with the
      given identity to become the primary communication method for that identity.

      Only one communication method per identity may be set as primary. If one already
      exists, change it to secondary to allow for this new one to be made primary.

      If the operation was successful return `:ok`. Otherwise return the error.
    """
    @callback make_primary(identity :: uuid, contact :: String.t) :: :ok | { :error, reason :: String.t }

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
    @callback verified?(identity :: uuid, contact :: String.t) :: { :ok, verified :: boolean } | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for requesting an unverified communication method be verified.
      This should generate the unique key that will be sent to the contact, that the
      requester will require in order to finalise the verification of that contact.

      If the communication method has already been verified, then it should return an error.

      If the operation was successful return `:ok`. Otherwise return an error.
    """
    @callback request_verification(identity :: uuid, contact :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for finalising a verification request of an unverified
      communication method.

      If the communication method has already been verified, then it should return an error.

      If the operation was successful return `:ok`. Otherwise return an error.
    """
    @callback finalise_verification(identity :: uuid, contact :: String.t, key :: String.t) :: :ok | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for retrieving the contacts of the communication method for
      the given identity.

      If the operation was successful return `{ :ok, contacts }`, where `contacts` is
      the list of communication methods associated with the given identity and their
      current verification status and priority. Otherwise return an error.
    """
    @callback contacts(identity :: uuid) :: { :ok, contacts :: [{ :unverified | :verified, :secondary | :primary, String.t }] } | { :error, reason :: String.t }

    @doc """
      Implement the behaviour for retrieving the primary contact of the communication
      method for the given identity.

      If the operation was successful return `{ :ok, contact }`, where `contact` is
      the primary communication method associated with the given identity. Otherwise return
      an error.
    """
    @callback primary_contact(identity :: uuid) :: { :ok, contact :: { :unverified | :verified, String.t } } | { :error, reason :: String.t }

    @doc """
      Associate a new contact with the given identity.

      If the contact is already in use, it will return an error.

      Returns `:ok` if the operation was successful, otherwise returns an error.
    """
    @spec add(atom, uuid, String.t) :: :ok | { :error, String.t }
    def add(type, identity, contact) do
        atom_to_module(type).add(identity, contact)
    end

    @doc """
      Remove the contact associated with the identity.

      Returns `:ok` if the operation was successful, otherwise returns an error.
    """
    @spec remove(atom, uuid, String.t) :: :ok | { :error, String.t }
    def remove(type, identity, contact) do
        atom_to_module(type).remove(identity, contact)
    end

    @doc """
      Change a contact associated with the identity to become a primary contact.

      Will turn any other primary contact for that identity into a secondary contact.

      Returns `:ok` if the operation was successful, otherwise returns an error.
    """
    @spec make_primary(atom, uuid, String.t) :: :ok | { :error, String.t }
    def make_primary(type, identity, contact) do
        atom_to_module(type).make_primary(identity, contact)
    end

    @doc """
      Request a contact be removed.

      If the contact is verified, then it should return an error.

      Returns `:ok` if the operation was successful, otherwise returns an error.
    """
    @spec request_removal(atom, String.t) :: :ok | { :error, String.t }
    def request_removal(type, contact) do
        atom_to_module(type).request_removal(contact)
    end

    @doc """
      Finalise the request that a contact be removed.

      If the contact is verified, then it should return an error.

      Returns `:ok` if the operation was successful, otherwise returns an error.
    """
    @spec finalise_removal(atom, String.t, String.t) :: :ok | { :error, String.t }
    def finalise_removal(type, contact, key) do
        atom_to_module(type).finalise_removal(contact, key)
    end

    @doc """
      Check if a contact belonging to the given identity has been verified.

      Returns `{ :ok, verified }` if the operation was successful, where `verified`
      is whether the email was verified (`true`) or not (`false`). Otherwise returns
      an error.
    """
    @spec verified?(atom, uuid, String.t) :: { :ok, boolean } | { :error, String.t }
    def verified?(type, identity, contact) do
        atom_to_module(type).verified?(identity, contact)
    end

    @doc """
      Request a contact be verified.

      If the contact is already verified, then it should return an error.

      Returns `:ok` if the operation was successful, otherwise returns an error.
    """
    @spec request_verification(atom, uuid, String.t) :: :ok | { :error, String.t }
    def request_verification(type, identity, contact) do
        atom_to_module(type).request_verification(identity, contact)
    end

    @doc """
      Finalise the verification request for a contact.

      If the contact is already verified, then it should return an error.

      Returns `:ok` if the operation was successful, otherwise returns an error.
    """
    @spec finalise_verification(atom, uuid, String.t, String.t) :: :ok | { :error, String.t }
    def finalise_verification(type, identity, contact, key) do
        atom_to_module(type).finalise_verification(identity, contact, key)
    end

    @doc """
      Get a list of contacts associated with the given identity.

      Returns `{ :ok, contacts }` if the operation was successful, where `contacts` is
      the list of communication methods associated with the given identity and their
      current verification status and priority. Otherwise returns the reason of failure.
    """
    @spec contacts(atom, uuid) :: { :ok, [{ :unverified | :verified, :secondary | :primary, String.t }] } | { :error, String.t }
    def contacts(type, identity) do
        atom_to_module(type).contacts(identity)
    end

    @doc """
      Get the primary contact associated with the given identity.

      Returns `{ :ok, contact }` if the operation was successful, where `contact` is
      the primary communication method associated with the given identity and its
      current verification status. Otherwise returns the reason of failure.
    """
    @spec primary_contact(atom, uuid) :: { :ok, { :unverified | :verified, String.t } } | { :error, String.t }
    def primary_contact(type, identity) do
        atom_to_module(type).primary_contact(identity)
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
