defmodule Sherbet.API.Mixfile do
    use Mix.Project

    def project do
        [
            app: :sherbet_api,
            version: "0.1.0",
            build_path: "../../_build",
            config_path: "../../config/config.exs",
            deps_path: "../../deps",
            lockfile: "../../mix.lock",
            elixir: "~> 1.4",
            elixirc_paths: elixirc_paths(Mix.env),
            build_embedded: Mix.env == :prod,
            start_permanent: Mix.env == :prod,
            deps: deps(),
            dialyzer: [plt_add_deps: :transitive]
        ]
    end

    # Configuration for the OTP application
    #
    # Type "mix help compile.app" for more information
    def application do
        [extra_applications: [:logger]]
    end

    # Specifies which paths to compile per environment.
    defp elixirc_paths(:test), do: ["lib", "test/support", "../sherbet_service/test/support"]
    defp elixirc_paths(_),     do: ["lib"]

    # Dependencies can be Hex packages:
    #
    #   {:my_dep, "~> 0.3.0"}
    #
    # Or git/path repositories:
    #
    #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    #
    # To depend on another app inside the umbrella:
    #
    #   {:my_app, in_umbrella: true}
    #
    # Type "mix help deps" for more examples and options
    defp deps() do
        [
            { :sherbet_service, in_umbrella: true, only: :test },
            { :defecto, github: "ScrimpyCat/Defecto", only: :test }
        ]
    end
end
