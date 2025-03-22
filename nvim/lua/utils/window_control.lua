local M = {}

-- delete buffers <<<
function M.delete_buffers(mode)
    local set_hidden = function()
        local hidden_status = vim.opt.hidden
        vim.opt.hidden = false
        vim.cmd("Alpha")
        vim.opt.hidden = hidden_status
    end

    local current_buf = vim.api.nvim_get_current_buf()

    -- Filter buffers that are listed and valid using vim.tbl_filter
    local buffers = vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "buflisted")
    end, vim.api.nvim_list_bufs())

    local switch_buffer_to_preserve_window_layout = function(windows)
        for _, win in ipairs(windows) do
            -- Identify the window of the current buffer
            if vim.api.nvim_win_get_buf(win) == current_buf then
                -- Find a buffer that can be shown instead of the current one
                for _, buf in ipairs(buffers) do
                    if buf ~= current_buf then
                        vim.api.nvim_win_set_buf(win, buf) -- Set the window to another buffer
                        break
                    end
                end
            end
        end
    end

    if mode == "active" then
        local windows = vim.api.nvim_tabpage_list_wins(0)
        if #windows > 1 and #buffers > 2 then
            switch_buffer_to_preserve_window_layout(windows)
        end
        vim.api.nvim_buf_delete(current_buf, { force = true })
        if #buffers == 1 then
            set_hidden()
        end

    elseif mode == "all" then
        for _, buf in ipairs(buffers) do
            vim.api.nvim_buf_delete(buf, { force = true })
        end
        set_hidden()

    elseif mode == "all_except_active" then
        for _, buf in ipairs(buffers) do
            if buf ~= current_buf then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
        vim.cmd("bufdo e")
    end
end
-- >>>

-- maximize window toggling <<<
local maximized_window_id = nil
local origin_window_id = nil

function M.max_win_toggle()
    if vim.fn.winnr("$") > 1 then
        -- There are more than one window in this tab
        if maximized_window_id then
            vim.cmd("wincmd w")
            vim.fn.win_gotoid(maximized_window_id)
        else
            origin_window_id = vim.fn.win_getid()
            vim.cmd("tab sp")
            maximized_window_id = vim.fn.win_getid()
        end
    else
        -- This is the only window in this tab
        if origin_window_id then
            vim.cmd("tabclose")
            vim.fn.win_gotoid(origin_window_id)
            maximized_window_id = nil
            origin_window_id = nil
        end
    end
end
-- >>>

return M
