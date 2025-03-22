local M = {}

function M.setup()

    local dap = require('dap')

    dap.adapters.python = {
        type = "executable",
        command = vim.fn.glob('/home/medwatt/miniforge3/envs/tensorflow-gpu/bin/python'),
        args = { "-m", "debugpy.adapter" },
        -- justMyCode = false
    }

    dap.configurations.python = {
        {
            type = 'python',
            request = 'launch',
            program = '${file}',
            -- cwd = '${workspaceFolder}',
            cwd = function()
                local filepath = vim.fn.expand('%:p:h')
                return filepath
            end,
            -- terminalKind = 'integratedTerminal',
            console = "integratedTerminal",
            -- justMyCode = false

            -- pythonPath = function()
            --     -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
            --     -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
            --     -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
            --     return "/usr/bin/python"
            -- end,
        }
    }

end

return M
