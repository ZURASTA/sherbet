defmodule Sherbet.Service.Contact.Communication.Method.Email.RemovalKey.Template do
    @moduledoc """
      Template used to create the email for remove email requests.

      ## Configuration

      There are two configuration options for this template. The first is customising
      the fields (sender, subject, link formats) used in the default template. The
      second is overriding the default template and replacing it with a completely
      custom one.

      The configuration falls under `:email`, `:removal`. e.g. `[email: [removal: ...]]`.

      ### Customising Fields

      Expects a keyword list configuring each field.

      * `:sender` - The from address of the email, can take the form of `email :: String.t`
      or `{ name :: String.t, email :: String.t }`.

      * `:subject` - The subject of the email, takes the form of `String.t`.

      * `:remove_link` - The removal link, takes the form of `((email, key) -> String.t)`.

        config :sherbet_service,
            email: [removal: [
                sender: { "Foo", "foo@bar" },
                subject: "Approve Email Removal",
                remove_link: &("https://example.com/remove/email/\#{&1}?key=\#{&2}")
            ]]

      ### Custom Formatter

      Expects a function returning the email. The function should be of the type
      `((email, key) -> Cake.Email)`.

        config :sherbet_service,
            email: [removal: fn email, key ->
                struct Cake.Email,
                    from: "foo@bar",
                    to: email
                    #...
            end]
    """
    alias Cake.Email
    alias Sherbet.Service.Contact.Communication.Method.Email.RemovalKey.Template

    defstruct [
        formatter: &Template.format/1,
        email: nil,
        key: nil
    ]

    def format(%{ email: email, key: key }) do
        case Application.get_env(:sherbet_service, :email, [removal: [
            sender: { "example", "noreply@example.com" },
            subject: "Remove Email",
            remove_link: &("https://example.com/remove?email=#{&1}&key=#{&2}")
        ]])[:removal] do
            formatter when is_function(formatter, 2) -> formatter.(email, key)
            state ->
                %Email{
                    from: state[:sender],
                    to: email,
                    subject: state[:subject],
                    body: %Email.Body{
                        text: """
                        Hello,

                        If you requested a removal link for #{email}. Please verify this by following the link #{state[:remove_link].(email, key)}

                        If you didn't please ignore this email, or request a verification link.
                        """
                    }
                }
        end
    end
end
