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
local function snippet_node_choice ()
    return sn (nil, {
            c(1,
                {
                    sn(1,
                        {
                            t({"\t{", "\t\t"}), i(1), t({"", "\t}"}),
                        }
                    ),
                    sn(2,
                        {
                            t({"\tfmta(", ""}),
                            t({"\t\t[[", "\t\t\t"}), i(1, "snippet"), t({"", "\t\t]],", ""}),
                            t({"\t\t{", "\t\t\t"}), i(2, "-- nodes"), t({"", "\t\t}", ""}),
                            t("\t)")
                        }
                    ),
                }
            ),
    })
end
-- >>>

return {

    -- s node <<<
    s({ trig = "s", dscr = "snippet node" },
        {
            t({"s(", "\t{ "}),
                t([[trig = "]]), i(1, "trigger"), t([[", ]]),
                t([[dscr = "]]), i(2, "description"), t([["]]),
            t({" },", ""}),

            d(3, snippet_node_choice),

            c(4,
                {
                    t(""),
                    sn(nil,
                        {
                            t({",", "\t{ condition = "}), i(1, "line_begin"), t(" }")
                        })
                }
            ),

            t({"","),"})
        },
        { condition = line_begin }
    ),
    -- >>>

    -- sn node <<<
    s({ trig = "sn", dscr = "snippet node" },
        {
            t("sn("), i(1, "index"), t({",", ""}),
            d(2, snippet_node_choice),
            t({"", "),"}),
        }
    ),
    -- >>>

    -- isn node <<<
    s({ trig = "isn", dscr = "snippet node" },
        {
            t("isn("), i(1, "index"), t({",", ""}),
            d(2, snippet_node_choice),
            t({", "}), i(3, '"$PARENT_INDENT"'), t({"", "),"}),
        }
    ),
    -- >>>

    -- t node <<<
    s(
        { trig = "t", dscr = "text node" },
        {
            c(1,
                {
                    sn(nil, { t("t("), r(1, "user_text"), t(")") }),
                    sn(nil, { t("t({"), r(1, "user_text"), t("})") }),
                }
            )
        },
        {
            stored = {
                ["user_text"] = i(1, "")
            }
        }
    ),
    -- >>>

    -- i node <<<
    s(
        { trig = "i", dscr = "insert node" },
        {
            t("i("), i(1, "index"), t(', "'), i(2, "text"), t('"'),
            c(3,
                {
                    t(""),
                    sn(nil,
                        {
                            -- use k("key-name") to reference a node with a key index
                            t(', {key = "'), i(1, "key-name"), t('"}')
                        }
                    ),
                }
            ),
            t(")")
        }
    ),

    -- >>>

    -- c node <<<
    s({ trig = "c", dscr = "choice node" },
        fmta(
            [[
            c(<>,
                {
                    <>
                }
            )
            ]],
            {
                i(1, 'index'),
                i(2, 'nodes'),
            })
    ),
    -- >>>

    -- f node <<<
    s(
        { trig = "f", dscr = "function node" },
        {
            t("f("), i(1, "function"), t(", "),
                     t("{ "), i(2, "comma_separated_node_references"), t(" }"),
                     c(3,
                         {
                            t(""),
                             sn(1,
                                {
                                    t(", { user_args = { "), i(1, "user_arg1, ..., user_argN "), t("} }"),
                                }
                             ),
                         }
                     ),
            t("),")
        }
    ),

    s(
        { trig = "ff", dscr = "function node function" },
        fmta(
            [[
                function(args, parent, user_arg1, ..., user_argN)

                    -- args: Gets its values from the { comma_separated_node_references } argument (second argument passed to the function node).
                    -- This is a table of tables, where each sub-table corresponds to a node's output.
                    -- args[1][1]: This accesses the first line (or entry) of the output of the first node.

                    -- parent: The parent node or snippet containing this function node.
                    -- You can use the `captures` field to access the captured groups from a regular expression trigger within a snippet.
                    -- parent.captures[1]: retrieves the first capture group.

                    -- user_args: These get their values from the { user_args = { user_arg1, ..., user_argN } } argument (third argument passed to the function node).

                    -- return a string without \n

                end
            ]],
            {
                -- nodes
            }
        )
    ),
    -- >>>

    -- d node <<<
    s(
        { trig = "d", dscr = "dynamic node" },
        {
            t("d("), i(1, "jump_index"), t(", "),
                     i(2, "function"),
                     c(3,
                         {
                             t(""),
                             sn(1,
                                {
                                    t(", { "), i(1, "node_references"), t(" }"),
                                    c(2,
                                        {
                                            t(""),
                                            sn(1,
                                                {
                                                    t(", { user_args = { "), i(1, "user_arg1, ..., user_argN "), t("} }"),
                                                }
                                            ),
                                        }
                                    ),
                                }
                            ),
                         }
                     ),
            t("),")
        }
    ),

    s(
        { trig = "df", dscr = "dynamic node function" },
        fmta(
            [[
                function(args, parent, old_state, user_arg1, ..., user_argN)

                    -- args: Gets its values from the { comma_separated_node_references } argument (second argument passed to the function node).
                    -- This is a table of tables, where each sub-table corresponds to a node's output.
                    -- args[1][1]: This accesses the first line (or entry) of the output of the first node.

                    -- parent: The parent node or snippet containing this function node.
                    -- You can use the `captures` field to access the captured groups from a regular expression trigger within a snippet.
                    -- parent.captures[1]: retrieves the first capture group.

                    -- user_args: These get their values from the { user_args = { user_arg1, ..., user_argN } } argument (third argument passed to the function node).

                    -- dynamic nodes must return a snippet node
                    return sn(nil,
                        {
                            -- nodes
                        }
                    )

                end
            ]],
            {
                -- nodes
            }
        )
    ),

    -- >>>

    -- visual node <<<
    s(
        { trig = "v", dscr = "visual node" },
        fmta(
            [[
                d(<>, h.get_visual)
            ]],
            {
                i(1, "jump_index")
            }
        )
    ),
    -- >>>

}
