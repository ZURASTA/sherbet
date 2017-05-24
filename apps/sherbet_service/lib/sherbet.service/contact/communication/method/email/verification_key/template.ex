defmodule Sherbet.Service.Contact.Communication.Method.Email.VerificationKey.Template do
    @moduledoc """
      Template used to create the email for verification email requests.

      ## Configuration

      There are two configuration options for this template. The first is customising
      the fields (sender, subject, link formats) used in the default template. The
      second is overriding the default template and replacing it with a completely
      custom one.

      The configuration falls under `:email`, `:verification`. e.g. `[email: [verification: ...]]`.

      ### Customising Fields

      Expects a keyword list configuring each field.

      * `:sender` - The from address of the email, can take the form of `email :: String.t`
      or `{ name :: String.t, email :: String.t }`.

      * `:subject` - The subject of the email, takes the form of `String.t`.

      * `:verify_link` - The verify link, takes the form of `((email, key) -> String.t)`.

      * `:request_removal_link` - The request removal link, takes the form of `(email -> String.t)`.

        config :sherbet_service,
            email: [verification: [
                sender: { "Foo", "foo@bar" },
                subject: "Approve Email Verification",
                verify_link: &("https://example.com/verify/email/\#{&1}?key=\#{&2}"),
                request_removal_link: &("https://example.com/removal_request/email/\#{&1}")
            ]]

      ### Custom Formatter

      Expects a function returning the email. The function should be of the type
      `((email, key) -> Cake.Email)`.

        config :sherbet_service,
            email: [verification: fn email, key ->
                struct Cake.Email,
                    from: "foo@bar",
                    to: email
                    #...
            end]
    """
    alias Cake.Email
    alias Sherbet.Service.Contact.Communication.Method.Email.VerificationKey.Template

    defstruct [
        formatter: &Template.format/1,
        email: nil,
        key: nil
    ]

    def format(%{ email: email, key: key }) do
        case Application.get_env(:sherbet_service, :email, [verification: [
            sender: { "example", "noreply@example.com" },
            subject: "Verify Email",
            verify_link: &("https://example.com/verify?email=#{&1}&key=#{&2}"),
            request_removal_link: &("https://example.com/removal_request?email=#{&1}")
        ]])[:verification] do
            formatter when is_function(formatter, 2) -> formatter.(email, key)
            state ->
                %Email{
                    from: state[:sender],
                    to: email,
                    subject: state[:subject],
                    body: %Email.Body{
                        text: """
                        Hello,

                        If you recently requested a verification link for #{email}. Please verify this by following the link #{state[:verify_link].(email, key)}

                        If you didn't you may request the email be removed by following the link #{state[:request_removal_link].(email)}
                        """
                    }
                }
        end
    end
end
