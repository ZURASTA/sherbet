defmodule Sherbet.Mixfile do
    use Mix.Project

    def project do
        [
            apps_path: "apps",
            build_embedded: Mix.env == :prod,
            start_permanent: Mix.env == :prod,
            aliases: aliases(),
            deps: deps(),
            dialyzer: [plt_add_deps: :transitive],
            name: "Sherbet",
            source_url: "https://github.com/ZURASTA/sherbet",
            docs: [
                main: "sherbet",
                extras: ["README.md": [filename: "sherbet", title: "Sherbet"]]
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
            { :ex_doc, "~> 0.18", only: :dev, runtime: false },
            { :simple_markdown, "~> 0.5.2", only: :dev, runtime: false },
            { :ex_doc_simple_markdown, "~> 0.2.1", only: :dev, runtime: false },
            { :simple_markdown_extension_blueprint, "~> 0.2", only: :dev, runtime: false },
            { :simple_markdown_extension_highlight_js, "~> 0.1.0", only: :dev, runtime: false },
            { :blueprint, "~> 0.3.1", only: :dev, runtime: false }
        ]
    end

    defp aliases do
        [docs: &build_docs/1]
    end

    defp build_docs(_) do
        System.cmd("mix", ["compile"], env: [{ "MIX_ENV", "prod" }])

        Mix.Tasks.Compile.run([])
        Mix.Tasks.Docs.run([])
    end
end
