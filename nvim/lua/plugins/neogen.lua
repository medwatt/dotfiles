require("neogen").setup {
    enabled = true,
    snippet_engine = "luasnip",
    enable_placeholders = true,
    languages = {
        lua = {
            template = {
                annotation_convention = "ldoc",
            },
        },
        python = {
            template = {
                annotation_convention = "google_docstrings", -- "numpydoc", "reST"
            },
        },
        rust = {
            template = {
                annotation_convention = "rustdoc",
            },
        },
        javascript = {
            template = {
                annotation_convention = "jsdoc",
            },
        },
        typescript = {
            template = {
                annotation_convention = "tsdoc",
            },
        },
        typescriptreact = {
            template = {
                annotation_convention = "tsdoc",
            },
        },
    },
}

-- local opts = { noremap = true, silent = true }
-- vim.keymap.set("n", "<tab>", function() require('neogen').jump_next() end, opts)
-- vim.keymap.set("n", "<S-tab>", function() require('neogen').jump_prev() end, opts)
