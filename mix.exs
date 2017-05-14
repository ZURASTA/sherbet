defmodule Sherbet.Mixfile do
    use Mix.Project

    def project do
        [
            apps_path: "apps",
            build_embedded: Mix.env == :prod,
            start_permanent: Mix.env == :prod,
            deps: deps(),
            dialyzer: [plt_add_deps: :transitive],
            name: "Sherbet",
            source_url: "https://github.com/ScrimpyCat/sherbet",
            docs: [
                main: "readme",
                extras: ["README.md"]
            ]
        ]
    end

    # Dependencies can be Hex packages:
    #
    #   {:my_dep, "~> 0.3.0"}
    #
    # Or git/path repositories:
    #
    #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    #
    # Type "mix help deps" for more examples and options.
    #
    # Dependencies listed here are available only for this project
    # and cannot be accessed from applications inside the apps folder
    defp deps do
        [
            { :ex_doc, "~> 0.15.1", only: :dev, runtime: false },
            { :simple_markdown, "~> 0.2.1", only: :dev, runtime: false }
        ]
    end
end
