defmodule Sherbet.API.Contact.Email do
    @moduledoc """
      Handles the management of email contacts.
    """

    @type uuid :: String.t

    @service Sherbet.Service.Contact
    @credential_type :email

    @doc """
      Associate an email with the given identity, and optionally specify its priority.

      #{Sherbet.API.option_docs}

      Returns `:ok` on successful addition. Otherwise returns a error.
    """
    @spec add(uuid, String.t, :secondary | :primary | keyword(any), keyword(any)) :: :ok | { :error, String.t }
    def add(identity, email, priority_or_options \\ [], options \\ [])
    def add(identity, email, priority, options) when is_atom(priority) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :add, { @credential_type, email, priority }, identity }, options[:timeout])
    end
    def add(identity, email, options, _) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :add, { @credential_type, email }, identity }, options[:timeout])
    end

    @doc """
      Remove an email that was associated with the given identity.

      #{Sherbet.API.option_docs}

      Returns `:ok` on successful removal. Otherwise returns an error.
    """
    @spec remove(uuid, String.t, keyword(any)) :: :ok | { :error, String.t }
    def remove(identity, email, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :remove, { @credential_type, email }, identity }, options[:timeout])
    end

    @doc """
      Set an email associated with the identity's priority.

      Will turn any other primary email contact for that identity into a secondary
      option.

      #{Sherbet.API.option_docs}

      Returns `:ok` on successful change. Otherwise returns an error.
    """
    @spec set_priority(uuid, String.t, :secondary | :primary, keyword(any)) :: :ok | { :error, String.t }
    def set_priority(identity, email, priority, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :set_priority, { @credential_type, email, priority }, identity }, options[:timeout])
    end

    @doc """
      Request an email associated with another identity, be removed.

      Removal requests only apply to unverified emails.

      #{Sherbet.API.option_docs}

      Returns `:ok` if request was successful. Otherwise returns an error.
    """
    @spec request_removal(String.t, keyword(any)) :: :ok | { :error, String.t }
    def request_removal(email, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :request_removal, { @credential_type, email } }, options[:timeout])
    end

    @doc """
      Finalise the request that an email be removed.

      #{Sherbet.API.option_docs}

      Returns `:ok` if removal was successful. Otherwise returns an error.
    """
    @spec finalise_removal(String.t, String.t, keyword(any)) :: :ok | { :error, String.t }
    def finalise_removal(email, key, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :finalise_removal, { @credential_type, email, key } }, options[:timeout])
    end

    @doc """
      Check if an email belonging to the given identity has been verified.

      #{Sherbet.API.option_docs}

      Returns `{ :ok, verified }` if the operation was successful, where `verified`
      is whether the email was verified (`true`) or not (`false`). Otherwise returns
      an error.
    """
    @spec verified?(uuid, String.t, keyword(any)) :: { :ok, boolean } | { :error, String.t }
    def verified?(identity, email, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :verified?, { @credential_type, email }, identity }, options[:timeout])
    end

    @doc """
      Request an email be verified.

      Verification requests only apply to unverified emails.

      #{Sherbet.API.option_docs}

      Returns `:ok` if request was successful. Otherwise returns an error.
    """
    @spec request_verification(uuid, String.t, keyword(any)) :: :ok | { :error, String.t }
    def request_verification(identity, email, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :request_verification, { @credential_type, email }, identity }, options[:timeout])
    end

    @doc """
      Finalise the verification request for an email.

      #{Sherbet.API.option_docs}

      Returns `:ok` if verification was successful. Otherwise returns an error.
    """
    @spec finalise_verification(uuid, String.t, String.t, keyword(any)) :: :ok | { :error, String.t }
    def finalise_verification(identity, email, key, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :finalise_verification, { @credential_type, email, key }, identity }, options[:timeout])
    end

    @doc """
      Check if an email belongs to the given identity.

      #{Sherbet.API.option_docs}

      Returns `{ :ok, belongs }` if the operation was successful, where `belongs`
      is whether the email belongs to the identity (`true`) or not (`false`). Otherwise
      returns an error.
    """
    @spec contact?(uuid, String.t, keyword(any)) :: { :ok, boolean } | { :error, String.t }
    def contact?(identity, email, options \\ []) do
        case verified?(identity, email, options) do
            { :ok, _ } -> { :ok, true }
            { :error, _ } -> { :ok, false }
        end
    end

    @doc """
      Get a list of emails associated with the given identity.

      #{Sherbet.API.option_docs}

      Returns `{ :ok, contacts }` if the operation was successful, where `contacts` is
      the list of emails associated with the given identity and their current verification
      status and priority. Otherwise returns the reason of failure.
    """
    @spec contacts(uuid, keyword(any)) :: { :ok, [{ :unverified | :verified, :secondary | :primary, String.t }] } | { :error, String.t }
    def contacts(identity, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :contacts, { @credential_type }, identity }, options[:timeout])
    end

    @doc """
      Get the primary email associated with the given identity.

      #{Sherbet.API.option_docs}

      Returns `{ :ok, contact }` if the operation was successful, where `contact` is
      the primary email associated with the given identity and its current verification
      status. Otherwise returns the reason of failure.
    """
    @spec primary_contact(uuid, keyword(any)) :: { :ok, { :unverified | :verified, String.t } } | { :error, String.t }
    def primary_contact(identity, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :primary_contact, { @credential_type }, identity }, options[:timeout])
    end

    @doc """
      Get the owning identity for the specific email.

      #{Sherbet.API.option_docs}

      Returns `{ :ok, identity }` if the operation was successful. Otherwise returns
      the reason of failure.
    """
    @spec owner(String.t) :: { :ok, uuid } | { :error, String.t }
    def owner(email, options \\ []) do
        options = Sherbet.API.defaults(options)
        GenServer.call(options[:server].(@service), { :owner, { @credential_type, email } }, options[:timeout])
    end
end
