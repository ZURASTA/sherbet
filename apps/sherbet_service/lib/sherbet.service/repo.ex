defmodule Sherbet.Service.Repo do
    @app :sherbet_service
    Sherbet.Service.Repo.Config.setup(@app, __MODULE__)
    use Ecto.Repo, otp_app: @app

    def child_spec(args) do
        %{
            id: __MODULE__,
            start: { __MODULE__, :start_link, [args] },
            type: :supervisor
        }
    end

    @on_load :setup_config
    defp setup_config() do
        Sherbet.Service.Repo.Config.setup(@app, __MODULE__)
        :ok
    end
end
