local M = {}

function M.setup(_)
    require('dap-python').setup('~/.local/share/nvim/mason/packages/debugpy/venv/bin/python')
end

return M
