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
local function code_block(args, snip)
    local buf_var = 'buf_code_block_language'
    if vim.b[buf_var] == nil then
        vim.b[buf_var] = vim.fn.input("Enter language: ")
    end
    return sn(nil, { t(vim.b[buf_var]) })
end
-- >>>

return {

    s(
        { trig = "cb", dscr = "code block" },
        {
            t("```{"), d(1, code_block), t({"}", ""}),
            i(2),
            t({"", "```", ""})
        },
        { condition = line_begin }
    ),

    s(
        { trig = "link", dscr = "insert link" },
        {
            t("["), i(1, "caption"), t("]("), i(2, "link"), t(")")
        },
        { condition = line_begin }
    ),

    s(
        { trig = "img", dscr = "insert image" },
        {
            t("!["), i(1, "caption"), t("]("), i(2, "link"), t(")")
        },
        { condition = line_begin }
    ),

    s(
        { trig = "mk", dscr = "inline math", snippetType = "autosnippet" },
        {
            t("$"), i(1), t("$")
        }
    ),

    s(
        { trig = "mx", dscr = "display math", snippetType = "autosnippet"},
        {
            t({"$$", "\t"}), i(1), t({"", "$$", ""})
        },
        { condition = line_begin }
    ),

}
