local M = {}

function M.setup()
    local dap = require "dap"
    require("dap").adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = "/home/medwatt/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb",
            args = { "--port", "${port}" },
        },
    }

    local config = {
        name = 'LLDB: Launch',
        type = 'codelldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
        console = 'integratedTerminal',
    }

    dap.configurations.c = { config }
    dap.configurations.cpp = { config }
end

return M
