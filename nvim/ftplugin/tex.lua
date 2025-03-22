local map = vim.keymap.set
local opt = { buffer = 0, noremap = true, silent = true }

-- Normal mode mappings
map('n', '<m-i>', 'ciw\\em{}<ESC><LEFT>p', opt)
map('n', '<m-b>', 'ciw\\textbf{}<ESC><LEFT>p', opt)
map('n', '<m-c>', 'ciw\\texttt{}<ESC><LEFT>p', opt)
map('n', '<m-f>', function()
    require('utils.funcs').format_adjacent_same_indent()
end, opt)

-- Visual mode mappings
map('v', '<m-i>', 'c\\em{}<ESC><LEFT>p', opt)
map('v', '<m-b>', 'c\\textbf{}<ESC><LEFT>p', opt)
map('v', '<m-c>', 'c\\texttt{}<ESC><LEFT>p', opt)


vim.api.nvim_create_user_command('TexWordCount', function() require("utils.funcs").TexWordCount() end, {})


local function format_latexindent_range(start_line, end_line)
    local home = os.getenv("HOME")
    local latexindent = home .. "/.local/share/nvim/mason/packages/latexindent/latexindent-linux"
    local config = home .. "/.config/nvim/lua/plugins/latexindent/settings.yaml"
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local text = table.concat(lines, "\n")
    local cmd = latexindent .. " -l " .. vim.fn.shellescape(config) .. " -"
    local formatted = vim.fn.system(cmd, text)
    if vim.v.shell_error ~= 0 then
        print("latexindent failed")
        return
    end
    local formatted_lines = vim.split(formatted, "\n", true)
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, formatted_lines)
end

local function format_selection()
    local mode = vim.fn.mode()
    local start_line, end_line
    if mode:match("[vV\22]") then
        start_line = vim.fn.line("v")
        end_line = vim.fn.line(".")
        if start_line > end_line then
            start_line, end_line = end_line, start_line
        end
    else
        start_line = 1
        end_line = vim.fn.line("$")
    end
    format_latexindent_range(start_line, end_line)
end

map("v", "=", format_selection, opt)
