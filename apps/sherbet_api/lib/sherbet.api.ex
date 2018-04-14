defmodule Sherbet.API do
    @moduledoc """
      The APIs for interfacing with the `Fondant.Service`.

      ## Configurable Options

      * `:server` - The server to send the request to. This takes a function
      that accepts a module and returns a valid named server.
      * `:timeout` - The maximum time to wait for a reply. This takes an
      `integer`.

      Some options for the API can be configured at the global level, or
      overridden per function. An example configuration:

        config :sherbet_api,
            server: &({ &1, :"foo@127.0.0.1" }),
            timeout: :infinity
    """

    @doc false
    def defaults(opts) do
        Keyword.merge([
            server: Application.get_env(:sherbet_api, :server, &(&1)),
            timeout: Application.get_env(:sherbet_api, :timeout, 5000)
        ], opts)
    end

    @doc false
    def option_docs() do
        """
        The options field accepts:

        * `:server` - The server to send the request to.
        * `:timeout` - The maximum time to wait for a reply.
        """
        |> String.trim_trailing
    end
end
