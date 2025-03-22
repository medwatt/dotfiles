require 'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "python",
        "cpp",
        "verilog",
        "lua",
        "vimdoc",
        "bash",
        "cmake",
        "latex", -- This needs tree-sitter binary
    },
    highlight = {
        enable = true,
        -- additional_vim_regex_highlighting = { 'python' },
        disable = function(lang, bufnr) -- Disable in large buffers
            local disabled_languages = { markdown = false , python = false, latex = false }
            if disabled_languages[lang] then
                return true
            end

            if vim.api.nvim_buf_line_count(bufnr) > 10000 then
                return true
            end

            return false
        end,
    },
    indent = {
        enable = false,
        -- disable = { "python" }
    },
    incremental_selection = {
        enable = true
    },
    -- rainbow = {enable = true}
}
