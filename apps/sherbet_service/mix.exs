defmodule Sherbet.Service.Mixfile do
    use Mix.Project

    def project do
        [
            app: :sherbet_service,
            version: "0.1.0",
            build_path: "../../_build",
            config_path: "../../config/config.exs",
            deps_path: "../../deps",
            lockfile: "../../mix.lock",
            elixir: "~> 1.4",
            elixirc_paths: elixirc_paths(Mix.env),
            build_embedded: Mix.env == :prod,
            start_permanent: Mix.env == :prod,
            aliases: aliases(),
            deps: deps(),
            dialyzer: [plt_add_deps: :transitive]
        ]
    end

    # Configuration for the OTP application
    #
    # Type "mix help compile.app" for more information
    def application do
        [
            mod: { Sherbet.Service, [] },
            extra_applications: [:logger]
        ]
    end

    # Specifies which paths to compile per environment.
    defp elixirc_paths(:test), do: ["lib", "test/support"]
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
    defp deps do
        [
            { :ecto, "~> 2.1" },
            { :postgrex, "~> 0.13.2" },
            { :protecto, github: "ScrimpyCat/Protecto" },
            { :defecto, github: "ScrimpyCat/Defecto", only: :test }
        ]
    end

    # Aliases are shortcuts or tasks specific to the current project.
    # For example, to create, migrate and run the seeds file at once:
    #
    #     $ mix ecto.setup
    #
    # See the documentation for `Mix` for more info on aliases.
    defp aliases do
        [
            "ecto.setup": ["ecto.create", "ecto.migrate"],
            "ecto.reset": ["ecto.drop", "ecto.setup"],
            "test": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]
        ]
    end
end
