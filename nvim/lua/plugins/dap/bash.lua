local M = {}

function M.setup()

    local dap = require('dap')
    local bash_debug = vim.fn.glob('~/.local/share/nvim/mason/packages/bash-debug-adapter/extension')

    dap.adapters.bashdb = {
        type = 'executable',
        command = 'node',
        args = { bash_debug..'/out/bashDebug.js' }
    }

    dap.configurations.sh = {
        {
            request = 'launch',
            type = 'bashdb',
            program = '${file}',
            args = {},
            env = {},
            pathBash = 'bash',
            pathBashdb = bash_debug..'/bashdb_dir/bashdb',
            pathBashdbLib = bash_debug..'/bashdb_dir',
            pathCat = 'cat',
            pathMkfifo = 'mkfifo',
            pathPkill = 'pkill',
            cwd = '${workspaceFolder}',
            terminalKind = 'integrated'
        }
    }

end

return M
