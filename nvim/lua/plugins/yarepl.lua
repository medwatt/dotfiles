local yarepl = require "yarepl"

-- functions <<<
local function begin_block_string()
    local comment_symbol = vim.bo.commentstring:match("([^%s]+)")
    return "^" .. comment_symbol .. "[%w%s]+{{{$"
end

local function end_block_string()
    local comment_symbol = vim.bo.commentstring:match("([^%s]+)")
    return "^" .. comment_symbol .. "%s+}}}$"
end

local function window (bufnr, name)
    -- row = math.floor(vim.o.lines * 0.25),
    -- col = math.floor(vim.o.columns * 0.25),
    local width = math.floor(vim.o.columns * 0.4)
    -- height = math.floor(vim.o.lines * 0.5),
    vim.cmd("vertical " .. width ..  " split")
    vim.api.nvim_set_current_buf(bufnr)
end
-- >>>

-- setup <<<
yarepl.setup {
    -- see `:h buflisted`, whether the REPL buffer should be buflisted.
    buflisted = false,
    -- whether the REPL buffer should be a scratch buffer.
    scratch = true,
    -- the filetype of the REPL buffer created by `yarepl`
    ft = 'REPL',
    -- How yarepl open the REPL window, can be a string or a lua function.
    -- See below example for how to configure this option
    -- wincmd = 'vertical 80 split',
    wincmd = window,
    -- The available REPL palattes that `yarepl` can create REPL based on
    metas = {
        python = { cmd = 'python', formatter = yarepl.formatter.trim_empty_lines },
        ipython = { cmd = 'ipython', formatter = yarepl.formatter.bracketed_pasting },
        lua = { cmd = 'lua', formatter = yarepl.formatter.trim_empty_lines },
        bash = { cmd = 'bash', formatter = yarepl.formatter.trim_empty_lines },
        zsh = { cmd = 'zsh', formatter = yarepl.formatter.bracketed_pasting },
    },
    -- when a REPL process exits, should the window associated with those REPLs closed?
    close_on_exit = true,
    -- whether automatically scroll to the bottom of the REPL window after sending
    -- text? This feature would be helpful if you want to ensure that your view
    -- stays updated with the latest REPL output.
    scroll_to_bottom_after_sending = true,
    os = {
        -- Some hacks for Windows. macOS and Linux users can simply ignore
        -- them. The default options are recommended for Windows user.
        windows = {
            -- Send a final `\r` to the REPL with delay,
            send_delayed_cr_after_sending = true,
        },
    },
    code_block = {
        begin_pattern = begin_block_string,
        end_pattern = end_block_string,
    },
}
-- >>>
