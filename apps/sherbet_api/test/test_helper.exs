Application.ensure_all_started(:sherbet_service)
Application.ensure_all_started(:ecto)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Sherbet.Service.Repo, :manual)
