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

-- __init__ args parse <<<
local function init_args_parse(args)
    local arg_str = args[1][1]
    local nodes = {}

    for arg in string.gmatch(arg_str, "[^,]+") do
        -- Trim any type hint or default value by removing anything after ':' or '='
        local clean_arg = string.match(arg, "^%s*([%a_][%w_]*)")
        if clean_arg then
            local text = "self." .. clean_arg .. " = " .. clean_arg
            table.insert(nodes, t({text, ""}))
        end
    end

    return isn(nil, nodes, "$PARENT_INDENT\t")
end
-- >>>


return {

    -- header <<<
    s(
        { trig = "#!", dscr = "header" },
        {
            t("#!/usr/bin/env python")
        },
        { condition = line_begin }
    ),
    -- >>>

    -- ifmain <<<
    s(
        { trig = "ifmain", dscr = "if main" },
        {
            t('if __name__ == "__main__":')
        },
        { condition = line_begin }
    ),
    -- >>>

    -- function <<<
    s(
        { trig = "fn", dscr = "function" },
        {
            c(1,
                {
                    t({""}),
                    t({"@staticmethod", ""}),
                    t({"@property", ""}),
                    t({"@classmethod", ""}),
                }
            ),
            t("def "), i(2, "function_name"), t("("),
            f(function(args)
                if #args[1][1] > 0 then
                    return "self, "
                end
                return ""
            end, { 1 }),
            i(3, "args"), t({"):", ""}),
            t("\t"), i(4, "pass")
        },
        { condition = line_begin }
    ),
    -- >>>

    -- reading/writing to a file <<<
    s(
        { trig = "fread", dscr = "Open and read a file" },
        {
            t("with open("), t('"'), i(1, "filename"), t('"'), t(', "r") as '), i(2, "file"), t({":", ""}),
            t("\t"), i(3, "content"), t(" = "), rep(2), t(".read()")
        },
        { condition = line_begin }
    ),

    s(
        { trig = "fwrite", dscr = "Open and write to a file" },
        {
            t("with open("), t('"'), i(1, "filename"), t('"'), t(', "w") as '), i(2, "file"), t({":", ""}),
            t("\t"), rep(2), t(".write("), i(3, "data"), t(")")
        },
        { condition = line_begin }
    ),
    -- >>>

    -- decorators <<<
    s(
        { trig = "deco", dscr = "decorator" },
        fmta(
            [[
            def <>(func):
                @wraps(func)
                def inner(*args, **kwargs):
                    # do something before function call
                    result = func(*args, **kwargs)
                    # do something after function call
                    return result
                return inner
            ]],
            {
                i(1, "decorator_name"),
            }
        ),
        { condition = line_begin }
    ),

    s(
        { trig = "decofac", dscr = "decorator factory" },
        fmta(
            [[
            def <>(<>):
                def decorator(func):
                    @wraps(func)
                    def inner(*args, **kwargs):
                        # do something with param before function call
                        result = func(*args, **kwargs)
                        # do something with param after function call
                        return result
                    return inner
                return decorator
            ]],
            {
                i(1, "decorator_name"),
                i(2, "parameters"),
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- class <<<
    -- init method <<<
    s(
        { trig = "init", dscr = "init" },
        {
            t("def __init__(self, "), i(1, "args"), t({"):", ""}),
            t("\t"),
            f(init_args_parse, { 1 }),
            d(2, init_args_parse, { 1 }),

        },
        { condition = line_begin }
    ),
    -- >>>

    -- container methods <<<
    s(
        { trig = "container", dscr = "methods for emulating a container type" },
        fmta(
            [[
                def __len__(self):
                    pass

                def __getitem__(self, key):
                    pass

                def __setitem__(self, key, value):
                    pass

                def __delitem__(self, key):
                    pass

                def __iter__(self):
                    pass

                def __reversed__(self):
                    pass

                def __contains__(self, item):
                    pass
            ]],
            {
                -- nodes
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- context manager methods <<<
    s(
        { trig = "contextmanager", dscr = "methods for context manager" },
        fmta(
            [[
                def __enter__(self):
                    pass

                def __exit__(self, exc_type, exc_value, traceback):
                    pass
            ]],
            {}
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- attribute access methods <<<
    s(
        { trig = "attraccess", dscr = "methods for customizing attribute access" },
        fmta(
            [[
                def __getattr__(self, name):
                    pass

                def __setattr__(self, name, value):
                    pass

                def __delattr__(self, name):
                    pass

                def __getattribute__(self, name):
                    pass
            ]],
            {}
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- descriptor methods <<<
    s(
        { trig = "descriptor", dscr = "methods for implementing descriptors" },
        fmta(
            [[
                def __get__(self, instance, owner):
                    pass

                def __set__(self, instance, value):
                    pass

                def __delete__(self, instance):
                    pass
            ]],
            {}
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- rich comparison methods <<<
    s(
        { trig = "richcmp", dscr = "methods for rich comparison" },
        fmta(
            [[
                def __eq__(self, other):
                    pass

                def __ne__(self, other):
                    pass

                def __lt__(self, other):
                    pass

                def __le__(self, other):
                    pass

                def __gt__(self, other):
                    pass

                def __ge__(self, other):
                    pass
            ]],
            {}
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- string representation methods <<<
    s(
        { trig = "strrepr", dscr = "methods for string representation" },
        fmta(
            [[
                def __str__(self):
                    pass

                def __repr__(self):
                    pass
            ]],
            {}
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- numeric type methods <<<
    s(
        { trig = "numeric", dscr = "methods for emulating a numeric type" },
        fmta(
            [[
                def __add__(self, other):
                    pass

                def __sub__(self, other):
                    pass

                def __mul__(self, other):
                    pass

                def __truediv__(self, other):
                    pass

                def __floordiv__(self, other):
                    pass

                def __mod__(self, other):
                    pass

                def __pow__(self, other):
                    pass

                def __neg__(self):
                    pass

                def __pos__(self):
                    pass

                def __abs__(self):
                    pass
            ]],
            {}
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- >>>

    -- try/except <<<
    s(
        { trig = "try", dscr = "try, except, else, finally" },
        fmta(
            [[
                try:
                    pass
                except <> as <>:
                    pass<>
            ]],
            {
                i(1, "exception"),
                i(2, "e"),
                c(3,
                    {
                        t({"", ""}),
                        sn(nil,
                            fmta(
                                [[
                                    <>
                                    else: # optional
                                        pass
                                    finally: # optional
                                        pass
                                ]],
                                {
                                    t({""}),
                                }
                            )
                        ),
                    }
                ),
            }
        ),
        { condition = line_begin }
    ),


    -- >>>

}
