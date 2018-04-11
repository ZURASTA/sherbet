# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

if Mix.env == :dev do
    import_config "simple_markdown_rules.exs"

    config :simple_markdown_extension_highlight_js,
        source: Enum.at(Path.wildcard(Path.join(Mix.Project.deps_path(), "ex_doc/formatters/html/dist/*.js")), 0, "")

    config :ex_doc_simple_markdown, [
        rules: fn rules ->
            :ok = SimpleMarkdownExtensionHighlightJS.setup
            SimpleMarkdownExtensionBlueprint.add_rule(rules)
        end
    ]

    config :ex_doc, :markdown_processor, ExDocSimpleMarkdown
end

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"
