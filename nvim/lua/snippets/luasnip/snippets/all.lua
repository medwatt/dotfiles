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
local function box(opts)
    local function box_width()
        return opts.box_width or vim.opt.textwidth:get()
    end

    local function padding(cs, input_text)
        local spaces = box_width() - (2 * #cs)
        spaces = spaces - #input_text
        return spaces / 2
    end

    return {
        f(function()
            local cs = h.comment_string()
            return string.rep(string.sub(cs, 1, 1), box_width())
        end, { 1 }),
        t({ "", "" }),
        f(function(args)
            local cs = h.comment_string()
            return cs .. string.rep(" ", math.floor(padding(cs, args[1][1])))
        end, { 1 }),
        i(1, "placeholder"),
        f(function(args)
            local cs = h.comment_string()
            return string.rep(" ", math.ceil(padding(cs, args[1][1]))) .. cs
        end, { 1 }),
        t({ "", "" }),
        f(function()
            local cs = h.comment_string()
            return string.rep(string.sub(cs, 1, 1), box_width())
        end, { 1 }),
    }
end

-- >>>

return {

    s(
        { trig = "box" },
        box({ box_width = 80 })
    ),

    s(
        { trig = "bbox" },
        box({ box_width = 40 })
    ),

    s(
        { trig = "fold", dscr = "vim fold" },
        {
            f(function() return h.comment_string() .. " " end, {}),
            i(1, "label"),
            t({ " <<<", "" }),
            d(2, h.get_visual),
            t({ "", "" }),
            f(function() return h.comment_string() end, {}),
            t({" >>>" }),
        }
    ),


}

