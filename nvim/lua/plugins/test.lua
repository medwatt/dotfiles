-- vim:fdm=marker

local ls = require("luasnip")
local lh = require("plugins.luasnip.luasnip_helper")

local i = ls.insert_node

-- make latex label {{{
local function make_latex_label(args, _, _)
    -- get sentence
    local sentence = args[1][1]
    -- remove non-alphanumeric characters
    local label = sentence:gsub("[^%a%d%s]", "")
    -- replace spaces with hyphens
    label = label:gsub("%s+", "-")
    -- convert to lower case
    label = label:lower()
    return label
end
-- }}}

-- create_environment function {{{
local function make_environment_snippet(_, _, _, env_name)
    local snip = sn(nil,
        fmta(
            [[
            \begin{<>}
                <>
            \end{<>}
            ]],
            {
                c(1, { t(env_name), t(env_name .. "*")}),
                i(2),
                rep(1),
            }
        )
    )
    return snip
end

local environment_snippet = ls.extend_decorator.apply(s, nil, {condition = lh.conds.line_begin})
-- }}}

-- make section snippet {{{
local function make_section_snippet(_, _, _, section_name, label)
    local snip = sn(nil,
        fmta(
            [[
                \<><>{<>}
                \label{<>:<>}
            ]],
            {
                t(section_name),
                c(1, { t(""),t("*") }),
                i(2, "title"),
                t(label),
                f(make_latex_label, {2})
            }
        )
    )
    return snip
end

local section_snippet = ls.extend_decorator.apply(s, nil, {condition = lh.conds.line_begin})
-- }}}

return {

    -- general environments {{{
    s(
        { trig = "beg(in)?", dscr = "begin ... end environment", regTrig = true, trigEngine = "ecma"},
        fmta(
            [[
            \begin{<>}
                <>
            \end{<>}
            ]],
            {
                i(1, "environment"),
                i(2),
                rep(1)
            }
        )
    ),

    environment_snippet( "abs",
        { d(1, make_environment_snippet, nil, {user_args = {"abstract"}}) }
    ),

    environment_snippet( "al",
        { d(1, make_environment_snippet, nil, {user_args = {"align"}}) }
    ),

    environment_snippet( "item",
        { d(1, make_environment_snippet, nil, {user_args = {"itemize"}}) }
    ),

    environment_snippet( "enum",
        { d(1, make_environment_snippet, nil, {user_args = {"enumerate"}}) }
    ),

    environment_snippet( "eq",
        { d(1, make_environment_snippet, nil, {user_args = {"equation"}}) }
    ),

    environment_snippet( "eqa",
        { d(1, make_environment_snippet, nil, {user_args = {"eqnarray"}}) }
    ),

    lh.auto(
        { trig = "--", dscr = "\\item in itemize and enumerate environments", hidden = true },
        { t("\\item") },
        { condition = lh.conds.in_bullets }
    ),

    lh.auto({ trig = "!-", dscr = "bullet point with custom text", hidden = true },
        fmta([[
            \item [<>]<>
            ]],
            { i(1), i(0) }
        ),
        { condition = lh.conds.in_bullets }
    ),
    -- }}}

    -- sections {{{
    section_snippet( "chap",
        { d(1, make_section_snippet, nil, {user_args = {"chapter", "cha"}}) }
    ),

    section_snippet( "#",
        { d(1, make_section_snippet, nil, {user_args = {"section", "sec"}}) }
    ),

    section_snippet( "##",
        { d(1, make_section_snippet, nil, {user_args = {"subsection", "sec"}}) }
    ),

    section_snippet( "###",
        { d(1, make_section_snippet, nil, {user_args = {"subsubsection", "sec"}}) }
    ),
    -- }}}

    -- math environments {{{

        lh.auto(
            { trig = "mk", dscr = "inline math" },
            {
                t("$"), i(1), t("$")
            }
        ),

        lh.auto(
            { trig = "mx", dscr = "display math" },
            fmta(
                [[
                    \[
                        <>
                    \]
                ]],
                {
                    i(1)
                }
            ),
            {condition = lh.conds.line_begin }
        ),
    -- }}}

    -- figure environments {{{

    -- single figure {{{
    s(
        { trig = "fig", dscr = "figure environment" },
        fmta(
            [[
            \begin{figure}[<>]
                \centering
                \includegraphics[width=<>\linewidth]{<>}
                \caption{<>}
                \label{fig:<>}
            \end{figure}
            ]],
            {
                i(1, "htpb"),
                i(2, "0.8"),
                i(3, "example-image-a"),
                i(4, "caption"),
                i(5, "label"),
            }
        ),
        {condition = lh.conds.line_begin }
    ),
    -- }}}

    -- minipage figures {{{
    s(
        { trig = "(%d+)figs?", dscr = "minipage figures", regTrig = true },
        fmta(
            [[
            \begin{figure}[<>]
                \centering
                <>
            \end{figure}
            ]],
            {
                i(1, "htpb"),

                d(2, function(_, snip)
                    local columns = tonumber(snip.captures[1])
                    local fig_size = tostring(math.floor(90 / columns) / 100)
                    local nodes = {}
                    for j = 1, columns do
                        local fig_node = isn(j,
                            fmta([[
                                \begin{minipage}[b]{<>\textwidth}
                                    \includegraphics[width=\linewidth]{<>}
                                    \caption{<>}
                                    \label{fig:<>}
                                \end{minipage}%
                                ]],
                                {
                                    t(fig_size),
                                    i(1, "example-image-a"),
                                    i(2, "caption"),
                                    i(3, "label_" .. j),
                                }
                            ),
                            "$PARENT_INDENT"
                        )
                        table.insert(nodes, fig_node)

                        if j == columns then
                                table.insert(nodes, t({""}))
                            else
                                table.insert(nodes, t({"", "\\hfill", ""}))
                        end

                    end
                    return isn(nil, nodes, "$PARENT_INDENT\t")
                end, nil)
            }
        ),
        {condition = lh.conds.line_begin }
        ),
    -- }}}

    -- subfigures arranged in a row {{{
    -- \usepackage{subcaption}
    s(
        { trig = "(%d+)subfigs?", dscr = "subfigures arranged in a row", regTrig = true },
        fmta(
            [[
            \begin{figure}[<>]
                \centering
                <>
                <>
            \end{figure}
            ]],
            {
                i(1, "htpb"),

                d(2, function(_, snip)
                    local columns = tonumber(snip.captures[1])
                    local fig_size = tostring(math.floor(90 / columns) / 100)
                    local nodes = {}
                    for j = 1, columns do
                        local fig_node = isn(j,
                            fmta([[
                                \begin{subfigure}{<>\textwidth}
                                    \centering
                                    \includegraphics[width=\linewidth]{<>}
                                    \caption{<>}
                                    \label{fig:<>}
                                \end{subfigure}%
                                ]],
                                {
                                    t(fig_size),
                                    i(1, "example-image-a"),
                                    i(2, "caption"),
                                    i(3, "label_" .. j),
                                }
                            ),
                            "$PARENT_INDENT"
                        )
                        table.insert(nodes, fig_node)

                        if j == columns then
                                table.insert(nodes, t({""}))
                            else
                                table.insert(nodes, t({"", "\\hfill", ""}))
                        end

                    end
                    return isn(nil, nodes, "$PARENT_INDENT\t")
                end, nil),

                isn(3,
                    fmta([[
                        \caption{<>}
                        \label{fig:<>}
                        ]],
                        {
                            i(1, "caption"),
                            i(2, "label"),
                        }
                    ),
                    "$PARENT_INDENT\t"
                )
            }
        ),
        {condition = lh.conds.line_begin }
    ),
    -- }}}

    -- subfigures arranged in a grid {{{
    -- \usepackage{subcaption}
    s(
        { trig = "(%d)x(%d)subfigs?", dscr = "subfigures arranged in a grid", regTrig = true },
        fmta(
            [[
            \begin{figure}[<>]
                \centering
                <>
                <>
            \end{figure}
            ]],
            {
                i(1, "htpb"),

                d(2, function(_, snip)
                    local rows = tonumber(snip.captures[1])
                    local columns = tonumber(snip.captures[2])
                    local fig_size = tostring(math.floor(100 / columns) / 100)
                    local nodes = {}
                    for j = 1, rows do
                        for k = 1, columns do
                            local fig_node = isn((j-1)*columns+k,
                                fmta([[
                                    \begin{subfigure}{<>\textwidth}
                                        \centering
                                        \includegraphics[width=0.8\linewidth]{<>}
                                        \caption{<>}
                                        \label{fig:<>}
                                    \end{subfigure}%
                                    ]],
                                    {
                                        t(fig_size),
                                        i(1, "example-image-a"),
                                        i(2, "caption"),
                                        i(3, "label_" .. j .. "_" .. k),
                                    }
                                ),
                                "$PARENT_INDENT"
                            )
                            table.insert(nodes, fig_node)

                            if k < columns then
                                table.insert(nodes, t({"", ""}))
                            end

                        end

                        if j < rows then
                            table.insert(nodes, t({"", "\\newline", ""}))
                        end
                    end

                    return isn(nil, nodes, "$PARENT_INDENT\t")
                end, nil),

                isn(3,
                    fmta([[
                        \caption{<>}
                        \label{fig:<>}
                        ]],
                        {
                            i(1, "caption"),
                            i(2, "label"),
                        }
                    ),
                    "$PARENT_INDENT\t"
                )
            }
        ),
        {condition = lh.conds.line_begin }
    ),
    -- }}}

    -- }}}

-- algorithm environments {{{

--  \usepackage{algorithm, algorithmic}
--  \REQUIRE and \ENSURE specify the input and output requirements.
--  \STATE defines a state or action in the algorithm.
--  Control structures like \WHILE, \IF, \ELSE, and \ENDIF help to construct the algorithm logic.

    s(
        { trig = "algorithm", dscr = "Algorithm environment" },
        fmta(
            [[
            \begin{algorithm}
                \caption{<>}
                \label{<>}
                \begin{algorithmic}[<>]
                    <>
                \end{algorithmic}
            \end{algorithm}
            ]],
            {
                i(1, "caption"),
                i(2, "label"),
                i(3, "1"),
                i(4),
            }
        ),
        {condition = lh.conds.line_begin }
    ),

-- }}}

    -- minted {{{
    -- \usepackage[cache=false]{minted}
    s(
        { trig = "minted", dscr = "minted block" },
        fmta(
            [[
            \begin{listing}[htpb]
            \begin{minted}[linenos,numbersep=5pt,frame=lines,framesep=2mm,autogobble]{<>}
            <>
            \end{minted}
            \caption{<>}
            \label{lst:<>}
            \end{listing}
            ]],
            {
                i(1, "python"),
                i(2),
                i(3, "caption"),
                i(4, "label")
            }
        ),
        {condition = lh.conds.line_begin }
    ),

    s(
        { trig = "mintedinline", dscr = "minted inline" },
        fmta(
            [[
            \mintinline{<>}{<>}
            ]],
            {
                i(1, "python"),
                i(2)
            }
        )
    ),

    -- }}}

-- beamer {{{

    -- frame {{{
    s(
        { trig = "frame", dscr = "frame environment" },
        fmta(
            [[
            % <> <<<<<<
            \begin{frame}<>{<>}
                <>
            \end{frame}
            % >>>>>>
            ]],
            {
                rep(2),
                c(1,
                    {
                        t(""),
                        sn(nil,
                            {
                                t("["), i(1, "fragile"), t("]")
                            }
                        )
                    }
                ),
                i(2, "title"),
                i(3),
            }
        ),
        {condition = lh.conds.line_begin }
    ),
    -- }}}

    -- columns {{{
    s(
        { trig = "(%d+)columns?", dscr = "columns", regTrig = true },
        fmta(
            [[
            \begin{columns}[<>]
                <>
            \end{columns}
            ]],
            {
                i(1, "b"),

                d(2, function(_, snip)
                    local columns = tonumber(snip.captures[1])
                    local fig_size = tostring(math.floor(90 / columns) / 100)
                    local nodes = {}
                    for j = 1, columns do
                        local fig_node = isn(j,
                            fmta([[
                                \begin{column}{<>\textwidth}
                                    <>
                                \end{column}%
                                ]],
                                {
                                    t(fig_size),
                                    i(1),
                                }
                            ),
                            "$PARENT_INDENT"
                        )
                        table.insert(nodes, fig_node)

                        if j == columns then
                                table.insert(nodes, t({""}))
                            else
                                table.insert(nodes, t({"", "", ""}))
                        end

                    end
                    return isn(nil, nodes, "$PARENT_INDENT\t")
                end, nil)
            }
        ),
        {condition = lh.conds.line_begin }
        ),
    -- }}}

-- }}}

    -- others {{{
    s(
        { trig = "pack", dscr = "add package" },
        fmta(
            [[
                \usepackage<>{<>}
            ]],
            {
                c(1, { t(""), sn(nil, { t("["), i(1, "options"), t("]") }) }),
                i(2, "package")
            }
        ),
        {condition = lh.conds.line_begin }
    ),
    -- }}}

}
