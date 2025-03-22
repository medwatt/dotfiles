local maximized_window_id = nil
local origin_window_id = nil
local M = {}

function M.run()
    if vim.fn.winnr('$') > 1 then
        -- There are more than one window in this tab
        if maximized_window_id then
            vim.cmd('wincmd w')
            vim.fn.win_gotoid(maximized_window_id)
        else
            origin_window_id = vim.fn.win_getid()
            vim.cmd('tab sp')
            maximized_window_id = vim.fn.win_getid()
        end
    else
        -- This is the only window in this tab
        if origin_window_id then
            vim.cmd('tabclose')
            vim.fn.win_gotoid(origin_window_id)
            maximized_window_id = nil
            origin_window_id = nil
        end
    end
end

return M
