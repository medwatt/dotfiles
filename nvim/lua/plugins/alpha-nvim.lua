local alpha = require("alpha")
local startify = require("alpha.themes.startify")

local config = {
    layout = {
        { type = "padding", val = 1 },
        -- startify.section.header,
        -- { type = "padding", val = 2 },
        startify.section.top_buttons,
        -- startify.section.mru,
        startify.section.mru_cwd,
        { type = "padding", val = 1 },
        { type = "text",    val = "BOOKMARKS", opts = { hl = "SpecialComment" } },
        { type = "padding", val = 1 },
        startify.section.bottom_buttons,
        { type = "padding", val = 1 },
        startify.section.footer,
    },
    opts = {
        margin = 3,
        redraw_on_resize = false,
        setup = function()
            vim.cmd([[
            autocmd alpha_temp DirChanged * lua require('alpha').redraw()
            ]])
        end,
    },
}

local buttons = {
    ["c"] = { path = "~/coding/", desc = "code" },
    ["g"] = { path = "~/git/", desc = "git" },
    ["l"] = { path = "~/Writing/LatexDocuments/", desc = "latex" },
    ["m"] = { path = "~/Writing/markdown/", desc = "markdown" },
    ["p"] = { path = "~/coding/projects/", desc = "projects" },
    ["s"] = { path = "~/circuit/", desc = "spice" },
    ["v"] = { path = "~/coding/HDL/VHDL/", desc = "vhdl" },
    ["w"] = { path = "~/coding/HDL/Verilog/", desc = "verilog" }
}

startify.section.bottom_buttons.val = {}

-- startify.section.bottom_buttons.val = {
--     startify.button("c", "code", "<cmd>NnnPicker cmd=nnn -x ~/coding/                            <CR>"),
--     startify.button("g", "git", "<cmd>NnnPicker cmd=nnn -x ~/git/                               <CR>"),
--     startify.button("l", "latex", "<cmd>NnnPicker cmd=nnn -x ~/Writing/LatexDocuments/            <CR>"),
--     startify.button("m", "markdown", "<cmd>NnnPicker cmd=nnn -x ~/Writing/markdown/                  <CR>"),
--     startify.button("p", "python", "<cmd>NnnPicker cmd=nnn -x ~/coding/python/                     <CR>"),
--     startify.button("s", "spice", "<cmd>NnnPicker cmd=nnn -x ~/circuit/                           <CR>"),
--     startify.button("v", "vhdl", "<cmd>NnnPicker cmd=nnn -x ~/coding/HDL/VHDL/                   <CR>"),
--     startify.button("w", "verilog", "<cmd>NnnPicker cmd=nnn -x ~/coding/HDL/Verilog/                <CR>"),
-- }

for key, val in pairs(buttons) do
    table.insert(
        startify.section.bottom_buttons.val,
        startify.button(key, val.desc,
                function()
                    require("mini.files").open(val.path)
                end)
        )
end

-----
-- startify.section.footer.val = {
--     startify.button("q", "Quit", "<cmd>q<CR>"),
-- }

startify.mru_opts.ignore = function(path, ext)
    local ext_ignore = { "gitcommit" }
    return (string.find(path, '/run/user/.*/firenvim') ~= nil)
        or (string.find(path, '/tmp/*') ~= nil)
        or (string.find(path, "COMMIT_EDITMSG"))
        or (vim.tbl_contains(ext_ignore, ext))
end

alpha.setup(config)
