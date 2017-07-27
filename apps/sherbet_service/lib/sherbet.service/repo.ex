defmodule Sherbet.Service.Repo do
    use Ecto.Repo, otp_app: :sherbet_service

    def child_spec(args) do
        %{
            id: __MODULE__,
            start: { __MODULE__, :start_link, [args] },
            type: :supervisor
        }
    end
end
