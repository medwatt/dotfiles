local map = vim.keymap.set
local opt = { buffer = 0, noremap = true, silent = true }

-- Normal mode mappings
map("n", "<m-i>", "ciw**<ESC><LEFT>p",         opt)
map("n", "<m-b>", "ciw****<ESC><LEFT><LEFT>p", opt)
map("n", "<m-c>", "ciw``<ESC><LEFT>p",         opt)
map("n", "<m-f>", function()
    require("utils.funcs").format_adjacent_same_indent()
end, opt)

-- Visual mode mappings
map("v", "<m-i>", "c**<ESC><LEFT>p",         opt)
map("v", "<m-b>", "c****<ESC><LEFT><LEFT>p", opt)
map("v", "<m-c>", "c``<ESC><LEFT>p",         opt)

--------------------------------------------------------------------------------
--                             Pandoc Convertions                             --
--------------------------------------------------------------------------------
local html_options = {
    "-H ~/.config/nvim/pandoc_files/css/pandoc.css",
    "-L ~/.config/nvim/pandoc_files/tex/md_latex_html_colors.lua",
    "% --mathjax -o %:r.html"
}

local pdf_options = {
    "-H ~/.config/nvim/pandoc_files/tex/preamble.tex",
    "-L ~/.config/nvim/pandoc_files/tex/md_latex_html_colors.lua",
    "--pdf-engine=xelatex --pdf-engine-opt=--shell-escape",
    "--pdf-engine-opt=-output-directory=build_dir",
    "--filter pandoc-minted",
    "% -o %:r.pdf",
}

local tex_options = {
    "-H ~/.config/nvim/pandoc_files/tex/preamble.tex",
    "--filter pandoc-minted",
    "% -o %:r.tex",
}

map("n", "<localleader>mhh", function()
    local cmd = "!pandoc -s " .. table.concat(html_options, " ")
    vim.cmd("silent write")
    vim.cmd(cmd)
end, { buffer = 0, noremap = true, desc = "convert to html"})

map("n", "<localleader>mho", function()
    local cmd = "!pandoc -s " .. table.concat(html_options, " ")
    cmd = cmd .. " && xdg-open %:r.html"
    vim.cmd("silent write")
    vim.cmd(cmd)
end, { buffer = 0, noremap = true, desc = "convert to html and open"})

map("n", "<localleader>mpp", function()
    local cmd = "!pandoc -s " .. table.concat(pdf_options, " ")
    vim.cmd("silent write")
    vim.cmd(cmd)
end, { buffer = 0, noremap = true, desc = "convert to pdf"})

map("n", "<localleader>mpo", function()
    local cmd = "!pandoc -s " .. table.concat(pdf_options, " ")
    cmd = cmd .. " && xdg-open %:r.pdf"
    vim.cmd("silent write")
    vim.cmd(cmd)
end, { buffer = 0, noremap = true, desc = "convert to pdf and open"})

map("n", "<localleader>mt", function()
    local cmd = "!pandoc -s " .. table.concat(tex_options, " ")
    vim.cmd("silent write")
    vim.cmd(cmd)
end, { buffer = 0, noremap = true, desc = "convert to tex"})

vim.cmd([[
    inoremap <silent> <Bar> <Bar><Esc>:call Markdown_Table_Align()<CR>a
]])
