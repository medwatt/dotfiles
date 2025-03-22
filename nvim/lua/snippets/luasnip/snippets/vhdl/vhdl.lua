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

return {

    -- package <<<
    s(
        { trig = "package", dscr = "package template" },
        fmt(
            [[
                library IEEE;
                use IEEE.STD_LOGIC_1164.ALL;

                package {} is

                    -- declare an enumeration
                    type colors is (red, blue, green);

                    -- declare a subtype
                    subtype my_int is integer range 0 to 15; -- from 0 to 15
                    subtype word is std_logic_vector(31 downto 0); -- 1 by 32 bits

                    -- declare array types
                    type mem_array_1 is array (0 to 31) of word; -- 32 by 32 bits
                    type mem_array_2 is array (natural range <>) of word; -- x by 32 bits
                    type mem_array_3 is array (natural range <>, natural range <>) of word; -- x by y by 32 bits

                    constant W : natural := 8;
                    constant B : integer := 16;
                    constant pi : real := 3.14159265359; -- only for simulation
                    constant my_word : word := (others => '0');
                    constant my_mem_array_1 : mem_array_1 := (others => (others => '0'));
                    constant my_mem_array_2 : mem_array_2(0 to 31) := (others => (others => '0'));
                    constant my_mem_array_3 : mem_array_3(0 to 3, 0 to 3) := (others => (others => (others => '0')));

                    function my_function(x, y, z : std_logic) return std_logic;
                    procedure my_procedure(signal x, y : in std_logic_vector(1 downto 0); signal z : out std_logic_vector(1 downto 0));

                end package {};

                package body {} is

                    function my_function(x, y, z : std_logic) return std_logic is
                        -- declarations
                    begin
                        return (x and y) or z;
                    end my_function;

                    procedure my_procedure(signal x, y : in std_logic_vector(1 downto 0); signal z : out std_logic_vector(1 downto 0)) is
                        -- declarations
                    begin
                        z <= x and y;
                    end my_procedure;

                end package body {};
            ]],
            { i(1, "package_name"), rep(1), rep(1), rep(1) }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- libraries <<<
    s(
        { trig = "libs", dscr = "Library" },
        fmta(
            [[
                library IEEE;
                use IEEE.STD_LOGIC_1164.ALL;
                use IEEE.NUMERIC_STD.ALL;
            ]],
            {
                nil
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- entity <<<
    s(
        { trig = "entity", dscr = "entity" },
        fmta(
            [[
                entity <> is<>
                    port(
                        <>
                    );
                end entity;
                ]],
            {
                i(1, "my_entity"),
                c(2,
                    {
                        t({ "" }),
                        sn(nil, fmta(
                            [[
                                <>
                                    generic (
                                        <>
                                    );
                                ]],
                            {
                                t({ "" }), i(1)
                            })
                        )
                    }
                ),
                i(3),
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- generic <<<
    s(
        { trig = "generic", dscr = "Generic" },
        fmta(
            [[
                    generic(
                        <>
                    );
                ]],
            {
                i(1)
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- architecture <<<
    s(
        { trig = "arch", dscr = "architecture" },
        fmta(
            [[
                architecture <> of <> is<>
                begin
                    <>
                end architecture;
                ]],
            {
                i(1, "beh"),
                i(2, "my_entity"),
                c(3,
                    {
                        sn(nil, { t({ "", "\t" }), i(1, "-- declarations") }), t({ "" })
                    }
                ),
                i(4),
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- process block <<<
    s(
        { trig = "process", dscr = "process block" },
        fmta(
            [[
                process(<>) is begin
                    <>
                end process;
                ]],
            {
                c(1,
                    {
                        t({ "" }),
                        i(1, "clk, rst")
                    }
                ),
                i(2, "-- process_body")
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- if <<<
    s(
        { trig = "if", dscr = "if block" },
        fmta(
            [[
                if <> then
                    <><>
                end if;
                ]],
            {
                i(1, "condition"),
                i(2),
                c(3,
                    {
                        t({ "" }),
                        sn(nil, fmta(
                            [[
                                <>
                                else
                                    <>
                                ]],
                            {
                                t(""), i(1)
                            })
                        ),
                        sn(nil, fmta(
                            [[
                                <>
                                elsif <> then
                                    <>
                                else
                                    <>
                                ]],
                            {
                                t(""), i(1, "condition"), i(2), i(3)
                            })
                        )
                    }
                )
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- if generate <<<
    s(
        { trig = "ifgen", dscr = "if generate" },
        fmta(
            [[
            <> : if <> generate
                <><>
            end generate;
        ]],
            {
                i(1, "label"),
                i(2, "condition"),
                i(3),
                c(4,
                    {
                        t({ "" }),
                        sn(nil, fmta(
                            [[
                            <>
                            -- VHDL 2008
                            else generate
                                <>
                            ]],
                            {
                                t(""), i(1)
                            })
                        ),
                        sn(nil, fmta(
                            [[
                            <>
                            -- VHDL 2008
                            elsif <> generate
                                <>
                            else generate
                                <>
                            ]],
                            {
                                t(""), i(1, "condition"), i(2), i(3)
                            })
                        )
                    }
                )
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- selected signal assignment <<<
    s(
        { trig = "select(%d*)", dscr = "selected signal assignment", regTrig = true },
        fmta(
            [[
            with <> select <> <<=
                <>
            ]],
            {
                i(1, "select_signal"),
                i(2, "output_signal"),
                d(3, function(_, snip)
                    local num_cases = math.max(tonumber(snip.captures[1]) or 2, 2)
                    local nodes = {}
                    for j = 1, num_cases do
                        local case_node = isn(j,
                            fmta(
                                [[
                                <> when <>
                                ]],
                                {
                                    i(1, "output_signal_value_" .. j),
                                    i(2, "condition_" .. j),
                                }
                            ),
                            "$PARENT_INDENT"
                        )
                        table.insert(nodes, case_node)

                        if j ~= num_cases then
                            table.insert(nodes, t({ ",", "" }))
                        else
                            table.insert(nodes, t({ ";" }))
                        end
                    end
                    return isn(nil, nodes, "$PARENT_INDENT\t")
                end, nil)
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- conditional signal assignment <<<
    s(
        { trig = "when(%d*)", dscr = "conditional signal assignment", regTrig = true },
        fmta(
            [[
            <> <<= <> when <> = <> else<>
            ]],
            {
                i(1, "output_signal"),
                i(2, "output_signal_value_1"),
                i(3, "select_signal", { key = "select-key" }),
                i(4, "select_signal_value_1"),
                d(5, function(_, snip)
                    local num_cases = tonumber(snip.captures[1]) or 2
                    num_cases = num_cases - 1
                    local nodes = {}
                    for j = 2, num_cases do
                        local case_node = isn(j - 1,
                            fmta(
                                [[
                                <><> when <> = <> else
                                ]],
                                {
                                    t({ "", "" }),
                                    i(1, "output_signal_value_" .. j),
                                    f(function(args) return args[1] end, k("select-key")),
                                    -- i(2, "select_signal"),
                                    i(2, "select_signal_value_" .. j),
                                }
                            ),
                            "$PARENT_INDENT"
                        )
                        table.insert(nodes, case_node)
                    end
                    if num_cases <= 1 then
                        table.insert(nodes,
                            sn(num_cases, { t(" "), i(1, "output_signal_value_" .. num_cases + 1), t({ ";" }) }))
                    else
                        table.insert(nodes,
                            sn(num_cases, { t({ "", "" }), i(1, "output_signal_value_" .. num_cases + 1), t({ ";" }) }))
                    end
                    return isn(nil, nodes, "$PARENT_INDENT\t")
                end, nil),
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- for <<<
    s(
        { trig = "for", dscr = "for loop" },
        fmta(
            [[
            for <> in <> to <>
                <>
            end for;
        ]],
            {
                i(1, "i"),
                i(2, "0"),
                i(3, "stop_value"),
                i(4)

            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- for generate <<<
    s(
        { trig = "forgen", dscr = "for generate loop" },
        fmta(
            [[
            <> : for <> in <> to <> generate
                <>
            end generate;
        ]],
            {
                i(1, "label"),
                i(2, "i"),
                i(3, "0"),
                i(4, "stop_value"),
                i(5)

            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- function <<<
    s(
        { trig = "function", dscr = "function" },
        fmta(
            [[
            function <> (<>) return <> is
                -- declarations
            begin
                <>
                return <>;
            end function <>;
        ]],
            {
                i(1, "function_name"),
                i(2, "x, y : std_logic; z : integer"),
                i(3, "return_type"),
                i(4),
                i(5, "expression"),
                rep(1)
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- procedure <<<
    s(
        { trig = "procedure", dscr = "Procedure" },
        fmta(
            [[
            procedure <> (<>) is
                -- declarations
            begin
                <>
            end procedure <>;
        ]],
            {
                i(1, "procedure_name"),
                i(2, "signal x : in std_logic; signal y : out std_logic"),
                i(3),
                rep(1)
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- configuration <<<
    s(
        { trig = "config", dscr = "Configuration" },
        fmta(
            [[
            configuration <> of <> is
                for <>
                    for <> : <>
                        use entity <>.<>(<>);
                    end for;
                end for;
            end configuration <>;
        ]],
            {
                i(1, "configuration_name"),
                i(2, "instantiating_entity_name"),
                i(3, "arch_name_of_instantiating_entity"),
                i(4, "component_instance_name"),
                i(5, "component_name_used_in_arch"),
                i(6, "library_name"),
                i(7, "entity_name_of_component"),
                i(8, "arch_name_of_component"),
                rep(1)
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- others <<<
    s(
        { trig = "others(%d*)", dscr = "others assignment", regTrig = true },
        {
            d(1, function(_, snip)
                local num_layers = tonumber(snip.captures[1]) or 1
                local inner_node = i(1, "0")
                local open_node = t(string.rep("(others => ", num_layers))
                local close_node = t(string.rep(")", num_layers))
                return sn(nil, { open_node, inner_node, close_node })
            end, nil),
        },
        { condition = line_begin }
    ),
    -- >>>

    -- enumerated data type <<<
    s(
        { trig = "enum", dscr = "enumeration" },
        fmta(
            [[
            type <> is (<>);
        ]],
            {
                i(1, "identifier"),
                i(2, "comma_separate_names"),
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- array <<<
    s(
        { trig = "array(%d*)", dscr = "array type", regTrig = true },
        fmta(
            [[
                <> (<>)<>
            ]],
            {

                c(1,
                    {
                        sn(nil, { t("type "), i(1, "new_type_identifier"), t(" is array ") }),
                        i(1, "type_identifier"),

                    }
                ),

                c(2,
                    {
                        f(function(_, snip)
                            local num_cases = tonumber(snip.captures[1]) or 1
                            local str = string.rep("natural range <>, ", num_cases - 1)
                            str = str .. "natural range <>"
                            return str
                        end, {}),

                        d(nil, function(_, snip)
                            local num_cases = tonumber(snip.captures[1]) or 1
                            local nodes = {}
                            for j = 1, num_cases - 1 do
                                table.insert(nodes, i(j))
                                table.insert(nodes, t(", "))
                            end
                            table.insert(nodes, i(num_cases))
                            return sn(nil, nodes)
                        end, nil),
                    }
                ),

                d(3, function(args, _)
                    if string.sub(args[1][1], 1, 5) == "type " then
                        return sn(nil, { t(" of "), i(1, "type_identifier"), t(";")})
                    else
                        return sn(nil, {t("")})
                    end
                end, {1}),

            }
        )
    ),
    -- >>>

-- subype <<<
    s(
        { trig = "subtype", dscr = "subtype" },
        fmta(
            [[
                subtype <> is <>;
            ]],
            {
                i(1, "identifier"),
                i(2),
            }
        ),
        {condition = line_begin }
    ),
-- >>>

    -- std_logic <<<
    s(
        { trig = "v", dscr = "std_logic_vector" },
        {
            t("std_logic_vector("),
            c(1,
                {
                    sn(1, { i(1), t(" down to "), i(2, "0") }),
                    sn(2, { i(1, "0"), t(" to "), i(2) })
                }
            ),
            t(")"),
        }
    ),

    s(
        { trig = "s", dscr = "std_logic" },
        {
            t("std_logic")
        }
    ),
    -- >>>

    -- fsm <<<
    s(
        { trig = "fsm", dscr = "State machine" },
        fmta(
            [[
                    -- this goes in the declaration section of the architecture
                    type state_type is (); -- add all possible states
                    signal state, next_state : state_type;

                    -- change state to next state on rising clock edge
                    sync_state: process (<>) begin
                        if(rising_edge(<>)) then
                            if(<> = '1') then
                                -- reset the state machine
                            else
                                -- update state of state machine
                                state <<= next_state;
                            end if;
                        end if;
                    end process sync_state;

                    -- next state logic (combinational)
                    -- add list of input signals to process sensitivity list
                    next_state_logic: process (state)
                    begin
                        -- insert logic here
                    end process state_output;

                    -- output logic (combinational)
                    -- add list of input signals to process sensitivity list
                    output_logic: process (state)
                    begin
                        -- insert logic here
                    end process state_output;
                ]],
            {
                i(1, "clk"),
                rep(1),
                i(2, "reset")
            }
        ),
        { condition = line_begin }
    ),
    -- >>>

}
