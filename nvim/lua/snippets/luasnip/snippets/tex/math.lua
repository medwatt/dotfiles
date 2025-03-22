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

-- snippet environments <<<
local maths = ls.extend_decorator.apply(
    s, { condition = h.math.in_math }
)

local automath = ls.extend_decorator.apply(
    s, { snippetType = "autosnippet" },
    { condition = h.math.in_math }
)
-- >>>

-- functions <<<
-- generate row of nodes <<<
local function generate_row_of_nodes(index, columns)
    index = tonumber(index)
    columns = tonumber(columns)
    local nodes = {}
    for j = 1, columns-1 do
        table.insert(nodes, i(j, tostring(j)))
        table.insert(nodes, t(" & "))
    end
    table.insert(nodes, i(columns, tostring(columns)))
    table.insert(nodes, t(" \\\\"))
    return sn(index, nodes)
end
-- >>>

-- generate table of nodes <<<
local function generate_table_of_nodes(rows, columns, indent_string)
    rows = tonumber(rows)
    columns = tonumber(columns)
    indent_string = indent_string or ""
    local nodes = {}
    for j = 1, rows-1 do
        print(j)
        table.insert(nodes, generate_row_of_nodes(j, columns))
        table.insert(nodes, t({"", ""}))
    end
    table.insert(nodes, generate_row_of_nodes(rows, columns))
    return isn(nil, nodes, "$PARENT_INDENT\t" .. indent_string)
end
-- >>>
-- >>>

return {

-- autosnippets <<<

    -- operators
    automath("!=",    { t([[\neq]]) }),
    automath("<=",    { t([[\leq]]) }),
    automath(">=",    { t([[\geq]]) }),
    automath("<<",    { t([[\ll]]) }),
    automath(">>",    { t([[\gg]]) }),
    automath("~~",    { t([[\sim]]) }),
    automath("~=",    { t([[\approx]]) }),
    automath("==",    { t([[\equiv]]) }),
    automath("=~",    { t([[\cong]]) }),
    automath(":=",    { t([[\definedas]]) }),
    automath("**",    { t([[\cdot]]) }),
    automath("xx",    { t([[\times]]) }),

    automath("@+",    { t([[\oplus]]) }),
    automath("@*",    { t([[\otimes]]) }),

    -- sets
    automath("NN",    { t([[\mathbb{N}]]) }),
    automath("ZZ",    { t([[\mathbb{Z}]]) }),
    automath("QQ",    { t([[\mathbb{Q}]]) }),
    automath("RR",    { t([[\mathbb{R}]]) }),
    automath("CC",    { t([[\mathbb{C}]]) }),
    automath("OO",    { t([[\emptyset]]) }),
    automath("pwr",   { t([[\powerset]]) }),
    automath("cc",    { t([[\subset]]) }),
    automath("cq",    { t([[\subseteq]]) }),
    automath("qq",    { t([[\supset]]) }),
    automath("qc",    { t([[\supseteq]]) }),

    -- quantifiers
    automath("AA",    { t([[\forall]]) }),
    automath("EE",    { t([[\exists]]) }),
    automath("inn",   { t([[\in]]) }),
    automath("notin", { t([[\not\in]]) }),
    automath("ooo",   { t([[\infty]]) }),
    automath("=>",    { t([[\implies]]) }),
    automath("=<",    { t([[\impliedby]]) }),
    automath("iff",   { t([[\iff]]) }),
    -- automath("||",    { t([[\divides]]) }),
    -- automath("!|",    { t([[\notdivides]]) }),

    -- arrows
    automath({ trig = "->", priority = 250 }, { t("\\to") }),
    automath({ trig = "-->", priority = 400 }, { t("\\longrightarrow") }),
    automath({ trig = "<->", priority = 500 }, { t("\\leftrightarrow") }),

    -- greek letters
    automath("a?",    { t([[\alpha]]) }),
    automath("b?",    { t([[\beta]]) }),
    automath("c?",    { t([[\varsigma]]) }),
    automath("d?",    { t([[\delta]]) }),
    automath("e?",    { t([[\varepsilon]]) }),
    automath("f?",    { t([[\varphi]]) }),
    automath("g?",    { t([[\gamma]]) }),
    automath("h?",    { t([[\eta]]) }),
    automath("i?",    { t([[\iota]]) }),
    automath("j?",    { t([[\theta]]) }),
    automath("k?",    { t([[\kappa]]) }),
    automath("l?",    { t([[\lambda]]) }),
    automath("m?",    { t([[\mu]]) }),
    automath("n?",    { t([[\nu]]) }),
    automath("o?",    { t([[\omicron]]) }),
    automath("p?",    { t([[\pi]]) }),
    automath("q?",    { t([[\chi]]) }),
    automath("r?",    { t([[\rho]]) }),
    automath("s?",    { t([[\sigma]]) }),
    automath("t?",    { t([[\tau]]) }),
    automath("u?",    { t([[\upsilon]]) }),
    automath("v?",    { t([[\phi]]) }),
    automath("w?",    { t([[\omega]]) }),
    automath("x?",    { t([[\xi]]) }),
    automath("y?",    { t([[\psi]]) }),
    automath("z?",    { t([[\zeta]]) }),

    automath("A?",    { t([[\Alpha]]) }),
    automath("B?",    { t([[\Beta]]) }),
    automath("C?",    { t([[\Varsigma]]) }),
    automath("D?",    { t([[\Delta]]) }),
    automath("E?",    { t([[\Varepsilon]]) }),
    automath("F?",    { t([[\Varphi]]) }),
    automath("G?",    { t([[\Gamma]]) }),
    automath("H?",    { t([[\Eta]]) }),
    automath("I?",    { t([[\Iota]]) }),
    automath("J?",    { t([[\Theta]]) }),
    automath("K?",    { t([[\Kappa]]) }),
    automath("L?",    { t([[\Lambda]]) }),
    automath("M?",    { t([[\Mu]]) }),
    automath("N?",    { t([[\Nu]]) }),
    automath("O?",    { t([[\Omicron]]) }),
    automath("P?",    { t([[\Pi]]) }),
    automath("Q?",    { t([[\Chi]]) }),
    automath("R?",    { t([[\Rho]]) }),
    automath("S?",    { t([[\Sigma]]) }),
    automath("T?",    { t([[\Tau]]) }),
    automath("U?",    { t([[\Upsilon]]) }),
    automath("V?",    { t([[\Phi]]) }),
    automath("W?",    { t([[\Omega]]) }),
    automath("X?",    { t([[\Xi]]) }),
    automath("Y?",    { t([[\Psi]]) }),
    automath("Z?",    { t([[\Zeta]]) }),

    -- math fonts
    automath("mbf",    { t("\\boldsymbol{"), i(1), t("}"), i(0) }),
    automath("mcal",   { t("\\mathcal{"), i(1), t("}"), i(0) }),
    automath("mscr",   { t("\\mathscr{"), i(1), t("}"), i(0) }),

    -- text
    automath("tt",     { t("\\text{"), i(1), t("}"), i(0) }),
    s("tc",            { t("\\textcolor{"), i(1, "blue"), t("}{"), i(2), t("}"), i(0) }),

    -- accents
    automath("vv",    { t("\\overrightarrow{"), i(1), t("}"), i(0) }),
    automath("bb",    { t("\\overline{"), i(1), t("}"), i(0) }),
    automath("hh",    { t("\\hat{"), i(1), t("}"), i(0) }),

    -- brackets
    automath("lr(",    { t("\\left( "), d(1, h.get_visual), t(" \\right)") }),
    automath("lr[",    { t("\\left[ "), d(1, h.get_visual), t(" \\right]") }),
    automath("lr{",    { t("\\left{ "), d(1, h.get_visual), t(" \\right}") }),
    automath("lr<",    { t("\\left< "), d(1, h.get_visual), t(" \\right>") }),
    automath("lr|",    { t("\\left| "), d(1, h.get_visual), t(" \\right|") }),

    -- commonly-used functions
    automath("sqrt",    { t("\\sqrt("), i(1), t(")") }),
    automath("ceil",    { t("\\left\\lceil "), i(1), t(" \\right\\rceil") }),
    automath("floor",   { t("\\left\\lfloor "), i(1), t(" \\right\\rfloor") }),


-- >>>

-- functions and expressions <<<
    maths("sum", fmta( [[\sum_{<>=<>}^{<>} <>]], { i(1, "n"), i(2, "1"), i(3, "\\infty"), i(4) })),
    maths("taylor", fmta( [[\sum_{<>=<>}^{<>} c_<> (x-a)^<>]], { i(1, "k"), i(2, "0"), i(3, "\\infty"), rep(1), rep(1) })),
    maths("prod", fmta( [[\prod_{<>=<>}^{<>} <>]], { i(1, "n"), i(2, "1"), i(3, "\\infty"), i(4) })),
    maths("binom", fmta( [[\binom{<>}{<>} ]], { i(1, "n"), i(2, "k") })),
    maths("lim", fmta( [[\lim_{<> \to <>} ]], { i(1, "n"), i(2, "\\infty") })),

    s("si", { t("\\SI{"), i(1, "3"), t("}{"), i(2, "\\meter\\per\\second\\squared"), t("}") }),
-- >>>

-- optimization <<<
    s(
        { trig = "optimize", dscr = "optimization problem" },
        fmta(
            [[
            \begin{equation}
                \begin{aligned}
                    \min_{<>}      \quad & <> \\
                    \textrm{s.t.} \quad & <> \\
                                        & <>
                \end{aligned}
            \end{equation}
            ]],
            {
                i(1, "variable"),
                i(2, "cost function"),
                i(3, "constraint equation"),
                i(4, "constraint equation"),
            }
        )
    ),
-- >>>

    -- fraction <<<
        automath(
            { trig = [[//]], dscr = "fraction (autoexpand)" },
            fmta(
                [[\frac{<>}{<>}<>]],
                { i(1), i(2), i(0) }
            )
        ),

        automath(
            { trig = [[((\d+)|(\d*)(\\)?([A-Za-z]+)((\^|_)(\{\d+\}|\d))*)/]], dscr = "fraction (autoexpand)", wordTrig = false, trigEngine = "ecma" },
            fmta(
                [[\frac{<>}{<>}<>]],
                {
                    f(function(_, snip) return snip.captures[1] end),
                    i(1),
                    i(0)
                }
            )
        ),
    -- >>>

-- derivatives <<<
    maths(
        { trig = "dd", dscr = "definite derivative" },
        c(1, {
            sn(nil,
                fmta(
                    [[\frac{\mathrm{d} <>}{\mathrm{d} <>}<>]],
                    {i(1, "y"), i(2, "x"), i(0)}
                )
            ),
            sn(nil,
                fmta(
                    [[\frac{\mathrm{d}^{<>} <>}{\mathrm{d} <>^{<>}}<>]],
                    {i(1, "n"), i(2, "y"), i(3, "x"), rep(1), i(0)}
                )
                ),
        })
    ),

    maths(
        { trig = "pp", dscr = "partial derivative" },
        c(1, {
            sn(nil,
                fmta(
                    [[\frac{\partial <>}{\partial <>}<>]],
                    {i(1, "y"), i(2, "x"), i(0)}
                )
            ),
            sn(nil,
                fmta(
                    [[\frac{\partial^{<>} <>}{\partial <>^{<>}}<>]],
                    {i(1, "n"), i(2, "y"), i(3, "x"), rep(1), i(0)}
                )
                ),
        })
    ),
-- >>>

-- integrals <<<
    maths(
        { trig = "[^%w_\\]int", dscr = "single integral", regTrig = true},
        fmta(
            [[\int<> <> \, \mathrm{d}<>]],
            {
                c(1, { t(""), sn(nil, { t("_{"), i(1, "a"), t("}^{"), i(2, "b"), t("}") }) }),
                i(2, "f(x)"),
                i(3, "x")
            }
        )
    ),

    maths(
        { trig = "[^%w_\\]oint", dscr = "loop integral", regTrig = true},
        fmta(
            [[\int<> <> \, \mathrm{d}<>]],
            {
                c(1, { t(""), sn(nil, { t("_{"), i(1, "C"), t("}") }) }),
                i(2, "f(r)"),
                i(3, "r")
            }
        )
    ),

    maths(
        { trig = "[^%w_\\]iint", dscr = "double integral", regTrig = true},
        fmta(
            [[\oiint<> <> <>]],
            {
                c(1, { t(""), sn(nil, { t("_{"), i(1, "D"), t("}") }) }),
                i(2, "f(x, y)"),
                c(3,
                    {
                        sn(1, { t("\\, \\mathrm{d}"), i(1, "x"), t(" \\, \\mathrm{d}"), i(2, "y") }),
                        sn(2, { t("\\, \\mathrm{d}"), i(1, "A")}),
                    }
                ),
            }
        )
    ),

    -- \usepackage{pxfonts}
    maths(
        { trig = "[^%w_\\]oiint", dscr = "surface integral", regTrig = true},
        fmta(
            [[\oiint<> <> <>]],
            {
                c(1, { t(""), sn(nil, { t("_{"), i(1, "S(V)"), t("}") }) }),
                i(2, "F"),
                c(3,
                    {
                        sn(1, { t("\\, \\mathrm{d}"), i(1, "S")}),
                        sn(2, { t("\\, \\mathrm{d}"), i(1, "x"), t(" \\, \\mathrm{d}"), i(2, "y") }),
                    }
                ),
            }
        )
    ),

    maths(
        { trig = "[^%w_\\]iiint", dscr = "triple integral", regTrig = true},
        fmta(
            [[\iiint<> <> <>]],
            {
                c(1, { t(""), sn(nil, { t("_{"), i(1, "V"), t("}") }) }),
                i(2, "f(x, y, z)"),
                c(3,
                    {
                        sn(1, { t("\\, \\mathrm{d}"), i(1, "x"), t(" \\, \\mathrm{d}"), i(2, "y"), t(" \\, \\mathrm{d}"), i(3, "z") }),
                        sn(2, { t("\\, \\mathrm{d}"), i(1, "V")}),
                    }
                ),
            }
        )
    ),

-- >>>

    -- subscript <<<
    automath(
        { trig = "__", dscr = "subscript", wordTrig = false },
        fmta([[_{<>}<>]], { i(1), i(0) })
    ),

    automath(
        { trig = [[(\b[A-Za-z])(\d)]], dscr = "subscript", wordTrig = false, trigEngine = "ecma" },
        {
            f(function(_, snip) return snip.captures[1] end),
            t("_"),
            f(function(_, snip) return snip.captures[2] end),
        }
    ),

    automath(
        { trig = [[(\b[A-Za-z])_(\d\d)]], dscr = "subscript", wordTrig = false, trigEngine = "ecma" },
        {
            f(function(_, snip) return snip.captures[1] end),
            t("_{"),
            f(function(_, snip) return snip.captures[2] end),
            i(1),
            t("}"),
            i(0),
        }
    ),
    -- >>>

    -- matrix <<<
    maths(
        {trig = "(%d+)x(%d+)([bBpvV])mat", name = "[bBpvV]matrix", dscr = "matrices", regTrig = true, hidden = true},
        fmta([[
            \begin{<>}
                <>
            \end{<>}]],
            {
                f(function(_, snip) return snip.captures[3] .. "matrix" end),

                d(1, function(_, snip)
                    return generate_table_of_nodes(snip.captures[1], snip.captures[2])
                end),

                f(function(_, snip) return snip.captures[3] .. "matrix" end)
            }
        )
    ),
    -- >>>

    -- table <<<
    s(
        { trig = "(%d+)x(%d)table", dscr = "table", regTrig = true },
        {
            c(1,
                {
                    sn(1,
                        fmta(
                            [[
                            \begin{table}[h]
                                \centering
                                \begin{tabular}{<>}
                                    \hline
                                    <>
                                    \hline
                                    <>
                                    \hline
                                \end{tabular}
                                \caption{<>}
                                \label{tbl:<>}
                            \end{table}
                            ]],
                            {
                                f(function(_, snip)
                                    return string.rep("|c", tonumber(snip.parent.captures[2]) - 1) .. "|c|"
                                end),

                                r(1, "node_1", d(1, function(_, snip)
                                    return generate_row_of_nodes(1, snip.snippet.captures[2])
                                end)),

                                r(2, "node_2", d(1, function(_, snip)
                                    return generate_table_of_nodes(snip.snippet.captures[1], snip.snippet.captures[2], "\t")
                                end)),

                                i(3, "caption"),
                                i(4, "label"),
                            }
                        )
                    ), -- end first choice

                    sn(1,
                        fmta(
                            [[
                            \begin{tabular}{<>}
                                \hline
                                <>
                                \hline
                                <>
                                \hline
                            \end{tabular}
                            ]],
                            {
                                f(function(_, snip)
                                    return string.rep("|c", tonumber(snip.parent.captures[2]) - 1) .. "|c|"
                                end),

                                r(1, "node_1", d(1, function(_, snip)
                                    return generate_row_of_nodes(1, snip.snippet.captures[2])
                                end)),

                                r(2, "node_2", d(1, function(_, snip)
                                    return generate_table_of_nodes(snip.snippet.captures[1], snip.snippet.captures[2])
                                end)),
                            }
                        )
                    ), -- end second choice

                }
            )

        },

        { condition = line_begin }
    ),
    -- >>>

-- parenthesis <<<

    -- LEFT/RIGHT PARENTHESES
    automath({ trig = "([^%a])l%(", regTrig = true, wordTrig = false },
        fmta(
            "<>\\left(<>\\right)",
            {
                f(function(_, snip) return snip.captures[1] end),
                d(1, get_visual),
            }
        )
    ),
    -- LEFT/RIGHT SQUARE BRACES
    automath({ trig = "([^%a])l%[", regTrig = true, wordTrig = false },
        fmta(
            "<>\\left[<>\\right]",
            {
                f(function(_, snip) return snip.captures[1] end),
                d(1, get_visual),
            }
        )
    ),
    -- LEFT/RIGHT CURLY BRACES
    automath({ trig = "([^%a])l%{", regTrig = true, wordTrig = false },
        fmta(
            "<>\\left\\{<>\\right\\}",
            {
                f(function(_, snip) return snip.captures[1] end),
                d(1, get_visual),
            }
        )
    ),
    -- BIG PARENTHESES
    automath({ trig = "([^%a])b%(", regTrig = true, wordTrig = false },
        fmta(
            "<>\\big(<>\\big)",
            {
                f(function(_, snip) return snip.captures[1] end),
                d(1, get_visual),
            }
        )
    ),
    -- BIG SQUARE BRACES
    automath({ trig = "([^%a])b%[", regTrig = true, wordTrig = false },
        fmta(
            "<>\\big[<>\\big]",
            {
                f(function(_, snip) return snip.captures[1] end),
                d(1, get_visual),
            }
        )
    ),
    -- BIG CURLY BRACES
    automath({ trig = "([^%a])b%{", regTrig = true, wordTrig = false },
        fmta(
            "<>\\big\\{<>\\big\\}",
            {
                f(function(_, snip) return snip.captures[1] end),
                d(1, get_visual),
            }
        )
    ),
    -- ESCAPED CURLY BRACES
    automath({ trig = "([^%a])\\%{", regTrig = true, wordTrig = false, priority = 2000 },
        fmta(
            "<>\\{<>\\}",
            {
                f(function(_, snip) return snip.captures[1] end),
                d(1, get_visual),
            }
        )
    ),
    -- LATEX QUOTATION MARK
    automath({ trig = "``" },
        fmta(
            "``<>''",
            {
                d(1, get_visual),
            }
        )
    ),
-- >>>

}

