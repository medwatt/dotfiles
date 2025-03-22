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

-- generate else / else if block <<<
local function generate_else_if ()
    -- The function to add elseif and else blocks dynamically
    return sn(nil, c(1, {
        t("end"),  -- No else or elseif, just end the if structure
        sn(nil, fmt([[
            elseif ({}) then
                {}
            {}
        ]],
        {
            i(1, "else_if_condition"),
            i(2, "action_else_if_true"),
            d(3, generate_else_if, {})  -- Recursive call to add more elseif or else blocks
        })),
        sn(nil, fmt([[
            else
                {}
            end
        ]], {
            i(1, "action_else"),
        }))
    }))
end
-- >>>

return {

    -- function <<<
    s(
        { trig = "fn", dscr = "lua function" },
        {
            c(1,
                { sn(1, { t("local function "), i(1, "function_name"), t(" ("), i(2, "args"), t({")", "\t"}), }),
                  sn(2, { t("local "), i(1, "function_name"), t(" = function ("), i(2, "args"), t({")", "\t"}), }),
                }
            ),
            i(2, "-- function body"),
            t({"", "end"}),
        },
        {condition =  line_begin}
    ),
    -- >>>

    -- if statement <<<
    s(
        { trig = "if", dscr = "if, else if, and else statements" },
        sn(1, fmt([[
            if {} then
                {}
            {}
        ]],
        {
            i(1, "condition"),
            i(2, "action_if_true"),
            d(3, generate_else_if, nil),
        })),
        { condition = line_begin }
    ),
    -- >>>

    -- for loop statement <<<
    s(
        { trig = "for", dscr = "for loop" },
        fmta(
            [[
                for <> do
                    <>
                end
            ]],
            {
                c(1,
                    {
                        sn(nil, { i(1, "i"), t(" = "), i(2, "1"), t(", "), i(3, "10"), t(", "), i(4, "1") }),
                        sn(nil, { i(1, "idx"), t(", "), i(2, "val"), t(" in ipairs("), i(3, "tbl"), t(")") }
                        )
                    }
                ),

                i(2),
            }
        ),
        {condition = line_begin }
    ),
    -- >>>

    -- while statement <<<
    s(
        { trig = "while", dscr = "while loop" },
        {
            t("while "), i(1, "condition"), t({" do", "\t"}),
            i(2, "--while body"),
            t({"", "end"}),
        },
        { condition = line_begin }
    ),
    -- >>>

}
