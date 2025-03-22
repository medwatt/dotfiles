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

    -- imports <<<
    s(
        { trig = "imports", dscr = "import common modules" },
        fmta(
            [[
                import numpy as np

                import matplotlib.pyplot as plt
                plt.style.use("/home/medwatt/quarto/matplotlib/science.mplstyle")
            ]],
            {

            }
        ),
        { condition = line_begin }
    ),
    -- >>>

    -- scatter plot <<<
    s(
        { trig = "scatterplot", dscr = "scatter plot" },
    fmta(
            [[
                ##########
                # Layout #
                ##########
                fig, ax1 = plt.subplots(figsize=(6, 4)) # 1 column figures: figsize=(3.5, 3)
                # ax2 = ax1.twinx()
                # ax3 = ax1.twinx()
                # ax3.spines["right"].set_position(("axes", 1.2))

                ########
                # Data #
                ########
                x = np.linspace(0, 4 * np.pi, 1000)
                plots = [
                    {
                        "axis": ax1,
                        "data": {
                            "x": x,
                            "y": np.sin(x)
                        },
                        "options": {
                            "label": "$\\sin(x)$",
                            "lw": 2.0,
                            "linestyle": '-',
                            "color": 'red'
                        }
                    },
                    {
                        "axis": ax1,
                        "data": {
                            "x": x,
                            "y": np.cos(x)
                        },
                        "options": {
                            "label": "$\\cos(x)$",
                            "lw": 2.0,
                            "linestyle": '--',
                            "color": 'orange'
                        }
                    },
                ]

                ##################
                # Generate Plots #
                ##################
                lines = []
                for plot in plots:
                    line, = plot["axis"].plot(*plot["data"].values(), **plot["options"])
                    lines.append(line)

                ###################
                #  Plot Settings  #
                ###################
                # ax1.set_title("Plot Title")
                ax1.set_xlabel("$x$")
                ax1.set_ylabel("$\\sin(x)$")
                # ax2.set_ylabel("$\\cos(x)$")

                # ax1.set_xscale("log")
                # ax1.set_yscale("log")
                # ax1.set_xlim([0, 10])
                # ax1.set_ylim([0, 1])

                # ax1.grid(which="both", color="gray", alpha=0.5, linestyle='dashed', linewidth=0.5)

                # from matplotlib.ticker import EngFormatter
                # ax1.xaxis.set_major_formatter(EngFormatter(unit='Hz'))

                # Setting plot ticks manually
                # ax1.set_yticks([1e1, 1e2, 1e3, 1e4, 1e5])
                # ax1.set_yticklabels(['10', '100', '1k', '10k', '100k'])

                # Annotations
                # ax1.axhline(y=0.5, color='r', linestyle='--')
                # ax1.axvline(x=2, color='b', linestyle='-')
                # ax1.text(1, 0.5, "Text Annotation", fontsize=12, color='green')

                ############
                #  Legend  #
                ############
                labels = [line.get_label() for line in lines]
                ax1.legend(lines, labels, loc="upper center", bbox_to_anchor=(0.5, 1.15), ncol=len(lines))

                ##########
                #  Save  #
                ##########
                plt.show()
                # fig.savefig(save_location + "scatterplot.svg", bbox_inches="tight")
            ]],
            {

            }
        ),
        { condition = line_begin }
    ),
    -- >>>

}
