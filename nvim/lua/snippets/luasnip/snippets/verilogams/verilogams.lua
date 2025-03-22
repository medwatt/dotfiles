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

-- parse module port list <<<
local function parse_port_list (args)
    local port_names = vim.split(args[1][1], ",", { trimempty = true })
    local nodes = {}
    table.insert(nodes, t({"", ""}))
    for _, port_name in ipairs(port_names) do
        port_name = port_name:gsub("%s+", "")
        table.insert(nodes, t({
            "inout " .. port_name .."; " .. "electrical " .. port_name .. ";",
            ""
        }))
    end
    return isn(nil, nodes, "$PARENT_INDENT\t")
end
-- >>>

-- parse module for parameter and port names <<<
local function parse_module(module_text)

    local insert_matches = function(matches, result_table)
        for _, match in ipairs(matches) do
            if match then
                for param in match do
                    table.insert(result_table, param)
                end
            end
        end
    end

    local module_name = module_text:match("module%s+([%w_]+)%s*") or "ModuleName"
    local module_parameters = {}
    local module_signals = {}

    -- Define block patterns
    local parameter_pattern = "#%(([^%)]+)%)"
    local port_pattern = "[^#]%(([^;]+)%)"

    -- Extract blocks
    local parameter_block = module_text:match(parameter_pattern) or ""
    local port_block = module_text:match(port_pattern) or ""

    -- Find parameters
    local parameter_with_type_pattern = "parameter%s+%w+%s([%w_]+)%s*="
    local parameter_without_type_pattern = "parameter%s([%w_]+)%s*="
    local parameter_match_table = {
        parameter_block:gmatch(parameter_with_type_pattern),
        parameter_block:gmatch(parameter_without_type_pattern)
    }
    insert_matches(parameter_match_table, module_parameters)

    -- Find ports
    local port_name_pattern1 = "%s([%w_]+)%s*,"
    local port_name_pattern2 = "%s([%w_]+)%s*$"
    local port_match_table = {
        port_block:gmatch(port_name_pattern1),
        port_block:gmatch(port_name_pattern2)
    }
    insert_matches(port_match_table, module_signals)

    return module_name, module_parameters, module_signals
end

local function create_instance_from_module_definition(_, parent)
    selected_text = table.concat(parent.snippet.env.LS_SELECT_RAW)

    if (#parent.snippet.env.LS_SELECT_RAW > 0) then

        local function make_sub_snippet(index, tbl, begin_paren, end_paren)
            local nodes = {}
            if #tbl > 0 then
                table.insert(nodes, t(begin_paren))
                for idx, v in ipairs(tbl) do
                    table.insert(nodes, t({"", "\t." .. v .. "(" .. v .. ")"}))
                    if idx ~= #tbl then
                        table.insert(nodes, t(","))
                    end
                end
                table.insert(nodes, t({"", end_paren}))
            end
            return sn(index, nodes)
        end

        local module_name, parameters, ports = parse_module(selected_text)

        return sn(index,
            {
                t(module_name .. " "),
                make_sub_snippet(2, parameters, "#(", ") "),
                i(1, "instance_name"),
                t(" "),
                make_sub_snippet(3, ports, "(", ");")
            }
        )
    else
        return sn(nil, i(1, ""))
    end
end
-- >>>

-- generate else / else if block <<<
local function generate_else_if ()
    -- The function to add else if and else blocks dynamically
    return sn(nil, c(1, {
        t(""),  -- No else or else if, just end the if structure
        sn(nil, fmt([[
            else if ({}) begin
                {}
            end
            {}
        ]],
        {
            i(1, "else_if_condition"),
            i(2, "action_else_if_true"),
            d(3, generate_else_if, {})  -- Recursive call to add more else if or else blocks
        })),
        sn(nil, fmt([[
            else begin
                {}
            end
        ]], {
            i(1, "action_else"),
        }))
    }))
end
-- >>>

-- generate case <<<
local function generate_case(_, _, _, indent)
    local indent_str = indent and "$PARENT_INDENT\t" or "$PARENT_INDENT"
    return isn(nil, fmt([[
        case({})
            {}: // Case item
                {}

            default:
                {}
        endcase
    ]],
    {
        i(1, "expression"),
        i(2, "value"),
        i(3, "// Implement actions for this case"),
        i(4, "// Implement default actions")
    }), indent_str)
end
-- >>>

-- generate ternary <<<
local function generate_ternary(node_index, current_depth)
    if current_depth <= 1 then
        node_index = node_index or nil
        return sn(node_index, fmt("{} ? {} : {}", {
                i(1, "condition" ),
                i(2, "value_if_true"),
                i(3, "value_if_false")
            })
        )
    else
        return isn(node_index, fmt([[
            {} ? ({})
            : ({})
            ]], {
                i(1, "condition_" .. tostring(current_depth)),
                generate_ternary(2, current_depth - 1),  -- Recursive call for true case
                generate_ternary(3, current_depth - 1),  -- Recursive call for false case
            }), "$PARENT_INDENT" .. string.rep("\t", 3))
    end
end
-- >>>

return {

    -- module <<<
    s(
        { trig = "module", dscr = "verilogams module" },
        {
            t({'`include "disciplines.vams"', '`include "constants.vams"', "", ""}),
            t("module "), i(1, "module_name"), t(" ("), i(2, "port_list"), t({");"}),
            t({"", "\t// Port Declaration"}),
            d(3, parse_port_list, {2}),
            t({"", "\t// Parameter Declration", ""}),
            t({"", "\t// Variables Declration", ""}),
            t({"", "\tanalog begin", ""}),
            t({"\t\t@(initial_step) begin", "\t\t\t// Initialize Variables Here", "\t\tend", ""}),
            t({"\t\t// Module Body", ""}),
            t({"\tend", ""});
            t({"", "endmodule"});
        },
        { condition = line_begin }
    ),
    -- >>>

    -- instantiating a module <<<
    s(
        { trig = "inst", dscr = "instantiating a systemverilog module" },
            {
                i(1, "ModuleName"),
                t(" "),
                c(2, {
                    t(""),  -- No parameters
                    sn(nil, fmt([[
                         #(
                            .{}({}), // Parameter 1
                            .{}({}), // Parameter 2
                            {}
                        ){}
                    ]], {
                        i(1, "PARAM1"),
                        i(2, "value1"),
                        i(3, "PARAM2"),
                        i(4, "value2"),
                        i(5, "// Additional parameters"),
                        t(" "),
                    }))
                }),
                i(3, "instance_name"),
                c(4, {
                    sn(1,
                        {
                            t(" ("),
                            i(1, "out1, in1, in2"),
                            t(")"),
                        }
                    ),
                    sn(2, fmt([[
                         (
                            .{}({}), // Port 1
                            .{}({}), // Port 2
                            {}
                        )
                    ]], {
                        i(1, "signal1"),
                        i(2, "net1"),
                        i(3, "signal2"),
                        i(4, "net2"),
                        i(5, "// Additional connections"),
                    }))
                }),
            }
    ),
    -- >>>

    -- instantiating from a module definition <<<
    s({ trig = "modinst", dscr = "instantiate a systemverilog module from module definition" }, {
        d(1, create_instance_from_module_definition),
    }),
    -- >>>

    -- if statement <<<
    s(
        { trig = "if", dscr = "if, else if, and else statements" },
        sn(1, fmt([[
            if ({}) begin
                {};
            end
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

     -- case statement <<<
    s(
        { trig = "case", dscr = "case statement" },
        c(1, {
            -- First choice: Only the case statement
            sn(1, {
                d(1, generate_case, nil, {user_args={false}})
            }),
            -- Second choice: always_comb block wrapping the case statement
            sn(2, {
                t({"always_comb", "\t"}),
                d(1, generate_case, nil, {user_args={true}}),
                t({"", "end"}),
            })
        }),
        { condition = line_begin }
    ),

    -- >>>

    -- always block <<<
    s(
        { trig = "always", dscr = "always block" },
        c(1, {
            -- always_ff block for synchronous logic
            fmt([[
                always_ff @(posedge {} or negedge {}) begin
                    if ({} == 1'b0) begin
                        {}
                    end else begin
                        {}
                    end
                end
            ]], {
                i(1, "clk"),
                i(2, "rst_n"),
                rep(2),
                i(3, "// Reset logic here"),
                i(4, "// Non-reset logic here")
            }),
            -- always_comb block for combinational logic
            fmt([[
                always_comb begin
                    {}
                end
            ]], {
                i(1, "// Combinational logic here")
            }),
            -- always_latch block for latching logic
            fmt([[
                always_latch begin
                    if ({}) begin
                        {}
                    end
                end
            ]], {
                i(1, "condition"),
                i(2, "// Latching logic here")
            })
        }),
        { condition = line_begin }
    ),
    -- >>>

    -- ternary operator <<<
    s(
        { trig = "ternary(%d*)", regTrig = true, dscr = "ternary operator"},
        d(1, function(_, snip)
            local depth = tonumber(snip.captures[1]) or 1
            return generate_ternary(nil, depth)
        end, {}),
        { condition = line_begin }
    ),
    -- >>>

    -- for loop <<<
    s(
        { trig = "for", dscr = "for loop" },
        fmt([[
            for ({} = {}; {} <= {}; {} = {} + 1) begin : {}
                {}
            end
        ]], {
            i(1, "i"),
            i(2, "0"),
            rep(1),
            i(3, "N"),
            rep(1),
            rep(1),
            i(4, "genblk"),
            i(5, "// Contents of the loop")
        }),
        { condition = line_begin }
    ),
    -- >>>

    -- for generate <<<
    s(
        { trig = "forgen", dscr = "for generate loop" },
        fmt([[
            genvar {}; // put this outside the analog block
            for ({} = {}; {} <= {}; {} = {} + 1) begin : {}
                {}
            end
        ]], {
            i(1, "i"),
            rep(1),
            i(2, "0"),
            rep(1),
            i(3, "N"),
            rep(1),
            rep(1),
            i(4, "genblk"),
            i(5, "// Contents of the generate loop")
        }),
        { condition = line_begin }
    ),
    -- >>>

    -- while <<<
    s(
        { trig = "while", dscr = "while" },
        {
            t("while ("), i(1, "condition"), t({") begin", ""}),
            t("\t"), i(2),
            t({"", "end"})
        },
        { condition = line_begin }
    ),
    -- >>>

    -- repeat <<<
    s(
        { trig = "repeat", dscr = "repeat" },
        {
            t("repeat ("), i(1, "condition"), t({") begin", ""}),
            t("\t"), i(2),
            t({"", "end"})
        },
        { condition = line_begin }
    ),
    -- >>>

    -- event expression <<<
    s(
        { trig = "@", dscr = "event expressions" },
        {
            t("@("), i(1, "/*event_expression_1 or event_expression_2 or ..*/"), t({") begin", "",}),
            t("\t"), i(2),
            t({"", "end"})
        },
        { condition = line_begin }
    ),
    -- >>>

    -- analog operators <<<
    s(
        { trig = "transition", dscr = "transition operator" },
        fmta(
            [[
                transition(<>, <>, <>)
            ]],
            {
                i(1, "signal"),
                i(2, "delay_time"),
                c(3,
                    {
                        i(1, "transition_time"),
                        sn(2, { i(1, "rise_time"), t(", "), i(2, "fall_time"), }),
                    }
                ),
            }
        ),
        { condition = line_begin }
    ),
    -- >>>


}
