Application.ensure_all_started(:gobstopper_service)
Application.ensure_all_started(:sherbet_service)
Application.ensure_all_started(:ecto)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Sherbet.Service.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Gobstopper.Service.Repo, :manual)
