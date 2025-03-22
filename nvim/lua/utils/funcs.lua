local M = {}

-- format adjacant lines <<<
function M.format_adjacent_same_indent()
    local api = vim.api
    local bufnr = api.nvim_get_current_buf()
    local current_line = api.nvim_win_get_cursor(0)[1]
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

    local function get_indent(line)

        local commentstring = vim.api.nvim_buf_get_option(0, 'commentstring'):gsub('%%s', '')

        if line:match("^%s*$") or line:match("^%s*" .. vim.pesc(commentstring)) then
            return nil, nil
        end

        if vim.api.nvim_buf_get_option(0, 'filetype') == "tex" then
            local ignore_cmds = {
                "^%s*\\%a+{%a+}$",
                "^%s*\\item",
            }
            for _, cmd in ipairs(ignore_cmds) do
                if line:match(cmd) then
                    return nil, cmd
                end
            end
        end

        return #(line:match("^%s*")), nil
    end

    local current_indent = #(lines[current_line]:match("^%s*"))

    local continue = true
    local start_line = current_line
    while continue and start_line > 1 do
        local previous_line, cmd  = get_indent(lines[start_line - 1])

        if previous_line ~= nil and previous_line <= current_indent then
            start_line = start_line - 1

        elseif cmd ~= nil and cmd == "^%s*\\item" then
            if lines[current_line]:match("^%s*\\item") == nil then
                start_line = start_line - 1
            end
            continue = false
        else
            continue = false
        end

    end

    continue = true
    local end_line = current_line
    while continue and end_line <#lines do
        local next_line, _ = get_indent(lines[end_line + 1])

        if next_line ~= nil and next_line >= current_indent then
            end_line = end_line + 1
        else
            continue = false
        end

    end

    if current_indent ~= nil then
        api.nvim_exec('normal! ' .. start_line .. 'GV' .. end_line .. 'G', false)
        api.nvim_exec('normal! gq', false)
    end
end
-- vim.api.nvim_create_user_command('FormatIndent', format_adjacent_same_indent, {})
-- >>>

-- LaTex Word Count <<<
function M.TexWordCount()
    -- Get the path of the active buffer
    local buffer_path = vim.api.nvim_buf_get_name(0)

    if vim.bo.filetype ~= "tex" then
        print("The file is not a TeX file")
        return
    end

    local cmd_path = "$XDG_CONFIG_HOME/nvim/others/texWordCount/texWordCount.pl"

    -- Define the command to run
    local cmd = cmd_path .. " " .. buffer_path

    -- Run the command and capture the output
    local output = vim.fn.system(cmd)

    -- Create a floating window
    local buf = vim.api.nvim_create_buf(false, true)
    local width = vim.o.columns
    local height = vim.o.lines
    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = math.ceil(width * 0.8),
        height = math.ceil(height * 0.8),
        col = math.ceil(width * 0.1),
        row = math.ceil(height * 0.1),
        style = 'minimal',
        border = 'rounded',
    })

    -- Set buffer content to the command output
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))

    -- Map 'q' to close the floating window
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
end
-- >>>

return M

