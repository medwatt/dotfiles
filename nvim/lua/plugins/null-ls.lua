local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local helpers = require("null-ls.helpers")

local sources = {

    -- null_ls.builtins.formatting.black.with({
    --     command = "/home/medwatt/.local/share/nvim/mason/packages/black/venv/bin/black",
    --     extra_args = {
    --         "--line-length=100",
    --     },
    -- }),

    null_ls.builtins.formatting.emacs_vhdl_mode,

    -- null_ls.builtins.formatting.latexindent.with({
    --     command = "/home/medwatt/.local/share/nvim/mason/packages/latexindent/latexindent-linux",
    --     extra_args = { "-m", "-l", "/home/medwatt/.local/share/nvim/mason/packages/latexindent/settings.yaml" },
    -- }),
}


null_ls.setup {
    debug = false,
    sources = sources
}

-- local luacheck_status_ok, luacheck = pcall(require, "plugins.null-ls.builtins.diagnostics.luacheck")
-- if luacheck_status_ok then
--     null_ls.register(luacheck.with({
--         command = "/home/medwatt/.local/share/nvim/mason/packages/luacheck/bin/luacheck",
--         extra_args = {
--             "--no-global",
--             "--std=luajit",
--         }
--     }))
-- end

local vcom_status_ok, vcom = pcall(require, "plugins.null-ls.builtins.diagnostics.vcom")
if vcom_status_ok then
    null_ls.register(vcom)
end

local vlog_status_ok, vlog = pcall(require, "plugins.null-ls.builtins.diagnostics.vlog")
if vlog_status_ok then
    null_ls.register(vlog)
end

local veriloga_status_ok, veriloga = pcall(require, "plugins.null-ls.builtins.diagnostics.veriloga")
if veriloga_status_ok then
    null_ls.register(veriloga)
end
