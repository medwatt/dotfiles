local function augroup(name)
    return vim.api.nvim_create_augroup("my_autocmd_" .. name, { clear = true })
end

------------------------------------------------------------------------
--                           new file types                           --
------------------------------------------------------------------------
local filetype = augroup("new_filetypes")

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.vhams", "*.vhdlams" },
    command = "set filetype=vhdlams",
    group = filetype,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.va", "*.vams" },
    callback = function()
        vim.cmd("set filetype=verilogams")
        vim.opt.commentstring = "// %s"
    end,
    group = filetype
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.v" },
    callback = function()
        vim.opt.commentstring = "// %s"
    end,
    group = filetype,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.cir" },
    command = "set filetype=spice",
    group = filetype,
})

-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--     -- pattern = { "*.lua", "*.tex"},
--     command = "set foldmarker=<<<,>>>",
--     group = augroup("fold"),
-- })

------------------------------------------------------------------------
--                               others                               --
------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    command = "setlocal formatoptions-=ro",
    group = augroup("opening_buffer")
})


local floating_buffers = vim.api.nvim_create_augroup("FloatingBuffers", { clear = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "Jaq", "dap-float" },
    callback = function()
        local opts = { noremap = true, silent = true, nowait = true, buffer = true }
        vim.keymap.set("n", "<esc>", ":q<CR>", opts)
        vim.keymap.set("n", "q", ":q<CR>", opts)
    end,
    group = floating_buffers,
})


-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
            return
        end
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- start insert mode when moving to a terminal window
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "TermOpen" }, {
    callback = function()
        if vim.bo.buftype == "terminal" then
            vim.cmd("startinsert")
        end
    end,
    group = augroup("vim_term")
})

-- local diagnostic_message = vim.api.nvim_create_augroup("DiagnosticMessage", { clear = true })
-- vim.api.nvim_create_autocmd({ "CursorHold" }, {
--     callback = function() vim.diagnostic.open_float(nil, { focus = false }) end,
--     group = diagnostic_message,
-- })
