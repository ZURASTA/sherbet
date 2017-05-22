defmodule Sherbet.Service.Contact.Communication.Method.Email.VerificationKey.Template do
    alias Cake.Email
    alias Sherbet.Service.Contact.Communication.Method.Email.VerificationKey.Template

    defstruct [
        formatter: &Template.format/1,
        email: nil,
        key: nil
    ]

    def format(%{ email: email, key: key }) do
        %Email{
            from: { "example", "noreply@example.com" },
            to: email,
            subject: "Verify Email",
            body: %Email.Body{
                text: """
                Hello,

                If you recently requested a verification link for #{email}. Please verify this by following the link https://example.com/verify?email=#{email}&key=#{key}

                If you didn't you may request the email be removed by following the link https://example.com/removal_request?email=#{email}
                """
            }
        }
    end
end
