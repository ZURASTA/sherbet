use Mix.Config

config :simple_markdown,
    rules: [
        line_break: %{ match: ~r/\A  $/m, format: "" },
        newline: %{ match: ~r/\A\n/, ignore: true },
        header: %{ match: ~r/\A(.*?)\n=+(?!.)/, option: 1, exclude: [:paragraph, :header] },
        header: %{ match: ~r/\A(.*?)\n-+(?!.)/, option: 2, exclude: [:paragraph, :header] },
        header: %{ match: ~r/\A(\#{1,6})(.*)/, option: fn _, [_, { _, length }, _] -> length end, exclude: [:paragraph, :header] },
        horizontal_rule: %{ match: ~r/\A *(-|\*)( {0,2}\1){2,} *(?![^\n])/, format: "" },
        horizontal_rule: %{ match: ~r/\A.*?\n(?= *(-|\*)( {0,2}\1){2,} *(?![^\n]))/, format: "" },
        horizontal_rule: %{ match: ~r/^.*?(?=\n[[:space:]]*\n *(-|\*)( {0,2}\1){2,} *(?![^\n]))/s, format: "" },
        table: %{
            match: ~r/\A(.*\|.*)\n((\|?[ :-]*?-[ :-]*){1,}).*((\n.*\|.*)*)/,
            capture: 4,
            option: fn input, i = [_, { title_index, title_length }, { align_index, align_length }|_] ->
                titles = binary_part(input, title_index, title_length) |> String.split("|", trim: true)
                aligns = binary_part(input, align_index, align_length) |> String.split("|", trim: true) |> Enum.map(fn
                    ":" <> align -> if String.last(align) == ":", do: :center, else: :left
                    align -> if String.last(align) == ":", do: :right, else: :default
                end)

                Enum.zip(titles, aligns)
            end,
            exclude: [:paragraph, :table],
            include: [row: %{
                match: ~r/\A(.*\|.*)+/,
                capture: 0,
                include: [separator: %{ match: ~r/\A\|/, ignore: true }]
            }]
        },
        table: %{
            match: ~r/\A((\|?[ :-]*?-[ :-]*){1,}).*((\n.*\|.*)+)/,
            capture: 3,
            option: fn input, [_, { align_index, align_length }|_] ->
                binary_part(input, align_index, align_length) |> String.split("|", trim: true) |> Enum.map(fn
                    ":" <> align -> if String.last(align) == ":", do: :center, else: :left
                    align -> if String.last(align) == ":", do: :right, else: :default
                end)
            end,
            exclude: [:paragraph, :table],
            include: [row: %{
                match: ~r/\A(.*\|.*)+/,
                capture: 0,
                include: [separator: %{ match: ~r/\A\|/, ignore: true }]
            }]
        },
        task_list: %{ match: ~r/\A- \[( |x|X)\] .*(\n- \[( |x|X)\] .*)*/, capture: 0, exclude: [:paragraph, :task_list], include: [task: %{ match: ~r/\A- \[ \] (.*)/, option: :deselected }, task: %{ match: ~r/\A- \[(x|X)\] (.*)/, option: :selected }] },
        list: %{ match: ~r/\A\*[[:blank:]]+([[:blank:]]*?[^[:blank:]\n].*?(\n|$))*/, capture: 0, option: :unordered, exclude: [:paragraph, :list], include: [item: %{ match: ~r/(?<=\*[[:blank:]])([[:blank:]]*?([^[:blank:]\*\n]|[^[:blank:]\n]\**?[^[:blank:]]).*?(\n|$))+/, capture: 0 }] },
        list: %{ match: ~r/\A[[:digit:]]\.[[:blank:]]+([[:blank:]]*?[^[:blank:]\n].*?(\n|$))*/, capture: 0, option: :ordered, exclude: [:paragraph, :list], include: [item: %{ match: ~r/(?<=[[:digit:]]\.[[:blank:]])([[:blank:]]*?([^[:blank:][:digit:]\n]|[^[:blank:]\n][[:digit:]]*?[^\.]).*?(\n|$))+/, capture: 0 }] },
        preformatted_code: %{ match: ~r/\A(\n*( {4,}|\t{1,}).*)+/, capture: 0, format: &(Regex.scan(~r/((?<=    )|(?<=\t)).*/, &1) |> Enum.join("\n")), rules: [] },
        preformatted_code: %{
            match: ~r/\A`{3}\h*?(\S+)\h*?\n(.*?)`{3}/s,
            option: fn input, [_, { syntax_index, syntax_length }|_] ->
                binary_part(input, syntax_index, syntax_length) |> String.to_atom
            end,
            format: &String.replace_suffix(&1, "\n", ""),
            rules: []
        },
        preformatted_code: %{ match: ~r/\A`{3}.*?\n(.*?)`{3}/s, format: &String.replace_suffix(&1, "\n", ""), rules: [] },
        paragraph: %{ match: ~r/\A(.|\n)*?\n{2,}/, capture: 0 },
        paragraph: %{ match: ~r/\A(.|\n)*(\n|\z)/, capture: 0 },
        emphasis: %{ match: ~r/\A\*\*(.+?)\*\*/, option: :strong, exclude: { :emphasis, :strong } },
        emphasis: %{ match: ~r/\A__(.+?)__/, option: :strong, exclude: { :emphasis, :strong } },
        emphasis: %{ match: ~r/\A\*(.+?)\*/, option: :regular, exclude: { :emphasis, :regular } },
        emphasis: %{ match: ~r/\A_(.+?)_/, option: :regular, exclude: { :emphasis, :regular } },
        blockquote: %{ match: ~r/\A>.*(\n([[:blank:]]|>).*)*/, capture: 0, format: &String.replace(&1, ~r/^> ?/m, ""), exclude: nil }, #(Regex.scan(~r/(?<=> ).*/, &1) |> Enum.join("\n")) },
        link: %{
            match: fn
                "[" <> input ->
                    if Regex.match?(~r/\A.*?\]\(.*\)/, input) do
                        find_end = fn
                            "[" <> string, _, n, fun -> fun.(string, :inner_mid, n + 1, fun)
                            "](" <> string, :inner_mid, n, fun -> fun.(string, :inner_end, n + 2, fun)
                            ")" <> string, :inner_end, n, fun -> fun.(string, :mid, n + 1, fun)
                            "](" <> string, :mid, n, fun -> fun.(string, :end, n + 2, fun)
                            ")" <> string, :end, n, _ -> n + 1
                            <<c :: utf8, string :: binary>>, token, n, fun -> fun.(string, token, n + byte_size(to_string([c])), fun)
                            "", _, n, _ -> n
                        end

                        [{ 0, find_end.(input, :mid, 1, find_end) }]
                    else
                        nil
                    end
                _ -> nil
            end,
            format: fn input ->
                [_, title, _] = Regex.run(~r/\A\[(.*?)\]\(([^\)\n]*?)\)$/, input)
                title
            end,
            option: fn input, [{ index, length}|_] ->
                [_, _, link] = Regex.run(~r/\A\[(.*?)\]\(([^\)\n]*?)\)$/, binary_part(input, index, length))
                link
            end
        },
        image: %{
            match: fn
                "![" <> input ->
                    if Regex.match?(~r/\A.*?\]\(.*\)/, input) do
                        find_end = fn
                            "[" <> string, _, n, fun -> fun.(string, :inner_mid, n + 1, fun)
                            "](" <> string, :inner_mid, n, fun -> fun.(string, :inner_end, n + 2, fun)
                            ")" <> string, :inner_end, n, fun -> fun.(string, :mid, n + 1, fun)
                            "](" <> string, :mid, n, fun -> fun.(string, :end, n + 2, fun)
                            ")" <> string, :end, n, _ -> n + 1
                            <<c :: utf8, string :: binary>>, token, n, fun -> fun.(string, token, n + byte_size(to_string([c])), fun)
                            "", _, n, _ -> n
                        end

                        [{ 0, find_end.(input, :mid, 2, find_end) }]
                    else
                        nil
                    end
                _ -> nil
            end,
            format: fn input ->
                [_, title, _] = Regex.run(~r/\A!\[(.*?)\]\(([^\)\n]*?)\)$/, input)
                title
            end,
            option: fn input, [{ index, length}|_] ->
                [_, _, link] = Regex.run(~r/\A!\[(.*?)\]\(([^\)\n]*?)\)$/, binary_part(input, index, length))
                link
            end
        },
        code: %{ match: ~r/\A`([^`].*?)`/, rules: [] }
    ]
