-- imports <<<
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key
local line_begin = require("luasnip.extras.conditions").line_begin
local h = require("snippets.luasnip.config.funcs")
-- >>>

-- functions <<<

-- make_generic_envirovment <<<
local function make_generic_envirovment (_, _, _, env)
    if env ~= nil then
        return sn(1,
            {
                t("\\begin{"), t(env), c(1, { t(""), t("*"), }), t({"}", ""}),
                i(2),
                t({"", "\\end{"}), t(env), rep(1), t({"}", ""})
            }
        )
    else
        return sn(1,
            {
                t("\\begin{"), i(1, "environment"), t({"}", ""}),
                i(2),
                t({"", "\\end{"}), rep(1), t({"}", ""})
            }
        )

    end
end
-- >>>

-- make_latex_label <<<
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
-- >>>

-- sections <<<
local function make_section_snippet (_, _, _, section_name, label_prefix)
    label_prefix = label_prefix or "sec"
    return sn(1,
        {
            t("\\"), t(section_name), c(1, { t(""), t("*"), }),
            t("{"), i(2, "title", {key = "title-key"}), t({"}", ""}),
            c(3,
                {
                    sn(1,
                        {
                            t("\\label{" .. label_prefix  .. ":"),
                            f(make_latex_label, { k("title-key") }),
                            t({"}", ""}),
                            i(1),
                            -- NOTE: The last i(1) node is necessary to make it possible to
                            -- switch between choice items.
                            -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#choicenode
                        }
                    ),
                    t(""),
                }
            ),
        }
    )
end


-- >>>

-- use_node_once <<<
local printed = {}
local function use_node_once (_, _, _, env, node)
    if printed[env] ~= true then
        printed[env] = true
        return sn(1, node )
    else
        return sn(1, t("") )
    end
end
-- >>>

-- >>>

return {

    -- sections <<<
    s(
        { trig = "part", dscr = "part" },
        d(1, make_section_snippet, nil, {user_args={"part", "part"}}),
        { condition = line_begin }
    ),
    s(
        { trig = "chap", dscr = "chapter" },
        d(1, make_section_snippet, nil, {user_args={"chap", "chap"}}),
        { condition = line_begin }
    ),
    s(
        { trig = "#", dscr = "section", priority=100 },
        d(1, make_section_snippet, nil, {user_args={"section"}}),
        { condition = line_begin }
    ),
    s(
        { trig = "##", dscr = "subsection", priority=101 },
        d(1, make_section_snippet, nil, {user_args={"subsection"}}),
        { condition = line_begin }
    ),
    s(
        { trig = "###", dscr = "subsubsection", priority=102 },
        d(1, make_section_snippet, nil, {user_args={"subsubsection"}}),
        { condition = line_begin }
    ),
    -- >>>

    -- common environments <<<
    s(
        { trig = "beg", dscr = "begin environment" },
        d(1, make_generic_envirovment, nil, {1}),
        { condition = line_begin }
    ),
    s(
        { trig = "abs", dscr = "abstract environment" },
        d(1, make_generic_envirovment, nil, {user_args={"abstract"}}),
        { condition = line_begin }
    ),
    s(
        { trig = "item", dscr = "itemize environment" },
        d(1, make_generic_envirovment, nil, {user_args={"itemize"}}),
        { condition = line_begin }
    ),
    s(
        { trig = "enum", dscr = "enumerate environment" },
        d(1, make_generic_envirovment, nil, {user_args={"enumerate"}}),
        { condition = line_begin }
    ),
    s(
        { trig = "eq", dscr = "equation environment" },
        d(1, make_generic_envirovment, nil, {user_args={"equation"}}),
        { condition = line_begin }
    ),
    -- >>>

    -- figure environments <<<

    -- single figure <<<
    s(
        { trig = "fig", dscr = "figure environment" },
        {
            c(1,
            {
                sn(2, fmta(
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
                            r(2, "width"),
                            r(3, "path"),
                            i(4, "caption"),
                            i(5, "label"),
                        }
                    )
                ),

                sn(1, fmta(
                        [[
                        \includegraphics[width=<>\linewidth]{<>}
                        ]],
                        {
                            r(1, "width"),
                            r(2, "path"),
                        }
                    )
                ),

            })
        },
        {
            stored = {
                ["width"] = i(1, "1"),
                ["path"] = i(2, "example-image-a"),
            },
            condition = line_begin
        }
    ),
    -- >>>

    -- minipage figures <<<
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
                            table.insert(nodes, t({ "" }))
                        else
                            table.insert(nodes, t({ "", "\\hfill", "" }))
                        end
                    end
                    return isn(nil, nodes, "$PARENT_INDENT\t")
                end, nil)
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- subfigures arranged in a row <<<
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
                            table.insert(nodes, t({ "" }))
                        else
                            table.insert(nodes, t({ "", "\\hfill", "" }))
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
        { condition = line_begin }
    ),
    -- >>>

    -- subfigures arranged in a grid <<<
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
                            local fig_node = isn((j - 1) * columns + k,
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
                                table.insert(nodes, t({ "", "" }))
                            end
                        end

                        if j < rows then
                            table.insert(nodes, t({ "", "\\newline", "" }))
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
        { condition = line_begin }
    ),
    -- >>>

    -- >>>

    -- math environments <<<
    s(
        { trig = "mk", dscr = "inline math", snippetType = "autosnippet" },
        {
            t("$"), i(1), t("$")
        }
    ),

    s(
        { trig = "mx", dscr = "display math", snippetType = "autosnippet"},
        {
            t({"\\[", "\t"}), i(1), t({"", "\\]", ""})
        },
        { condition = line_begin }
    ),

    -- >>>

    -- algorithm environments <<<
    -- \usepackage{algorithm, algorithmic}
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
        { condition = line_begin }
    ),
    -- >>>

    -- minted <<<
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
                i(1, "language"),
                i(2),
                i(3, "caption"),
                i(4, "label")
            }
        ),
        { condition = line_begin }
    ),

    s(
        { trig = "mintedinline", dscr = "minted inline" },
        fmta(
            [[
            \mintinline{<>}{<>}
            ]],
            {
                i(1, "language"),
                i(2)
            }
        )
    ),

    -- >>>

    -- beamer <<<

    -- frame <<<
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
        { condition = line_begin }
    ),
    -- >>>

    -- columns <<<
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
                            table.insert(nodes, t({ "" }))
                        else
                            table.insert(nodes, t({ "", "", "" }))
                        end
                    end
                    return isn(nil, nodes, "$PARENT_INDENT\t")
                end, nil)
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- >>>

    -- font <<<

    s(
        { trig = "tt", dscr = "\\texttt{}" },
        {
            t("\\texttt{"), d(1, h.get_visual), t("}")
        }
    ),

    s(
        { trig = "bf", dscr = "\\textbf{}" },
        {
            t("\\textbf{"), d(1, h.get_visual), t("}")
        }
    ),

    s(
        { trig = "em", dscr = "\\em{}" },
        {
            t("\\em{"), d(1, h.get_visual), t("}")
        }
    ),

    s(
        { trig = "ul", dscr = "\\underline{}" },
        {
            t("\\underline{"), d(1, h.get_visual), t("}")
        }
    ),
    -- >>>

    -- new commands <<<

    -- new command <<<
    s(
        { trig = "newcmd", dscr = "new command" },
        {
            d(1, use_node_once, nil, {
                user_args = {
                    "newenv",
                    t({
                        [[% Example: \newcommand{\redtext}[1]{\textcolor{#1}}]],
                        [[% Usage:   \redtext{This text will be red.}]],
                        ""
                    }),
                }
            }),
            c(2, { t("\\newcommand{\\"), t("\\renewcommand{\\") }), i(3, "name"), t("}"),
            c(4,
                {
                    t(""),
                    sn(1, { t("["), i(1, "num_of_args"), t("]"), })
                }
            ),
            t("{"), i(5, "definition"), t("}"),
        },
        { condition = line_begin }
    ),
    -- >>>

    -- new environment <<<
    s(
        { trig = "newenv", dscr = "new environment" },
        {
            d(1, use_node_once, nil, {
                user_args = {
                    "newenv",
                    t({
                        [[% Example: \newenvironment{coloredtext}[1]{\textcolor{#1}}{}]],
                        [[% Usage:   \begin{coloredtext}{red}]],
                        [[%          This text will be red.]],
                        [[%          \end{coloredtext}]],
                        ""
                    }),
                }
            }),
            c(2, { t("\\newenvironment{\\"), t("\\renewenvironment{\\") }), i(3, "name"), t("}"),
            t("{"), i(4, "begin code"), t("}"),
            t("{"), i(5, "end code"), t("}"),
        },
        { condition = line_begin }
    ),
    -- >>>

    -- >>>

    -- others <<<
    s(
        { trig = "--", dscr = "\\item" },
        {
            t("\\item")
        },
        { condition = line_begin }
    ),

    s(
        { trig = "ref", dscr = "reference" },
        {
            c(1,
                {
                    t("\\ref{"),
                    t("\\pageref{")
                }
            ),
            i(2, "marker"),
            t("}"),
        }
    ),

    s(
        { trig = "bib", dscr = "bibliography entry" },
        fmta(
                [[
                @<>{
                    author = {<>},
                    title = {<>},
                    year = {<>},
                    journal = {<>}
                }
                ]],
                {
                    i(1, "article"),
                    i(2, "Author Name"),
                    i(3, "Title of the Paper"),
                    i(4, "Year"),
                    i(5, "Journal Name")
                }
            ),
            { condition = line_begin }
        ),

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
        { condition = line_begin }
    ),
    -- >>>

}
