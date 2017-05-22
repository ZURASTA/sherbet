defmodule Sherbet.Service.Contact.Communication.Method.Email.RemovalKey.Template do
    alias Cake.Email
    alias Sherbet.Service.Contact.Communication.Method.Email.RemovalKey.Template

    defstruct [
        formatter: &Template.format/1,
        email: nil,
        key: nil
    ]

    def format(%{ email: email, key: key }) do
        %Email{
            from: { "example", "noreply@example.com" },
            to: email,
            subject: "Remove Email",
            body: %Email.Body{
                text: """
                Hello,

                If you requested a removal link for #{email}. Please verify this by following the link https://example.com/remove?email=#{email}&key=#{key}

                If you didn't please ignore this email, or request a verification link.
                """
            }
        }
    end
end
