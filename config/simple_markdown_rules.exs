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
        list: %{ match: ~r/\A\*[[:blank:]]+.*(\n([[:blank:]]|\*).*)*/, capture: 0, option: :unordered, exclude: [:paragraph, :list], include: [item: ~r/(?<=\* ).*/] },
        list: %{ match: ~r/\A[[:digit:]]\.[[:blank:]]+.*(\n([[:blank:]]|([[:digit:]]\.)).*)*/, capture: 0, option: :ordered, exclude: [:paragraph, :list], include: [item: ~r/(?<=\. ).*/] },
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
        blockquote: %{ match: ~r/\A>.*(\n([[:blank:]]|>).*)*/, capture: 0, format: &String.replace(&1, ~r/^> /m, ""), exclude: nil }, #(Regex.scan(~r/(?<=> ).*/, &1) |> Enum.join("\n")) },
        link: %{ match: ~r/\A\[(.*?)\]\((.*?)\)/, capture: 1, option: fn input, [_, _, { index, length }] -> binary_part(input, index, length) end },
        image: %{ match: ~r/\A!\[(.*?)\]\((.*?)\)/, capture: 1, option: fn input, [_, _, { index, length }] -> binary_part(input, index, length) end },
        code: %{ match: ~r/\A`([^`].*?)`/, rules: [] }
    ]
