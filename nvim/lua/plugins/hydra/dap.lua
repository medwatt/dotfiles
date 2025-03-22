-- imports <<<
local Hydra = require("hydra")
local dap = require("dap")
-- >>>

-- debugging menu <<<
local hint = [[
_s_: start / continue  _i_: step into
_r_: restart           _n_: step over
^^                     _o_: step out
_K_: eval              _c_: to cursor
^ ^
                      _q_: quit debugging
]]
-- >>>

-- func: dap functions <<<
local function StartDap()
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
    if filetype == 'lua' then
        require("osv").run_this()
    else
        dap.continue()
    end
end

local function TerminateDap()
    require('dapui').close()
    require('dap').repl.close()
    require('dap').terminate()
end
-- >>>

local dap_hydra = Hydra({
    name = "dap",
    mode = { "n", "x" },
    body = "<F5>",
    hint = hint,
    config = {
        color = "teal",
        invoke_on_body = true,
        hint = {
            show_name = true,
            position = "bottom-right",
            float_opts = {
                border = "single",
            },
        },
    },
    heads = {
        { "n", dap.step_over,                                { silent = true } },
        { "i", dap.step_into,                                { silent = true } },
        { "o", dap.step_out,                                 { silent = true } },
        { "c", dap.run_to_cursor,                            { silent = true } },
        { "r", dap.restart,                                  { silent = true } },
        { "s", StartDap,                                     { silent = true } },
        { "q", TerminateDap,                                 { silent = true, exit=true }},
        { "K", function() require('dap.ui.widgets').hover() end, { silent = true } },
        -- { "h", nil,                                          { exit = true, nowait = true } },
    }
})

dap_hydra:activate()

