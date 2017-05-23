defmodule Sherbet.Service.Contact.Communication.Method.Email.VerificationKey.Template do
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
