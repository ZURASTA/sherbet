defmodule Sherbet.Service.Contact.Communication.Method.Email.RemovalKey.Template do
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
