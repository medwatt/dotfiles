require("telescope").setup({
    extensions = {
        undo = {
            use_delta = true,
            use_custom_command = nil, -- setting this implies `use_delta = false`. Accepted format is: { "bash", "-c", "echo '$DIFF' | delta" }
            side_by_side = false,
            vim_diff_opts = {
                ctxlen = vim.o.scrolloff,
            },
            entry_format = "state #$ID, $STAT, $TIME",
            time_format = "",
            saved_only = true,
            mappings = {
                i = {
                    -- ["<cr>"] = require("telescope-undo.actions").yank_additions,
                    -- ["<cr>"] = require("telescope-undo.actions").yank_deletions,
                    ["<cr>"] = require("telescope-undo.actions").restore,
                    -- alternative defaults, for users whose terminals do questionable things with modified <cr>
                    -- ["<C-y>"] = require("telescope-undo.actions").yank_deletions,
                    -- ["<C-r>"] = require("telescope-undo.actions").restore,
                },
                -- n = {
                --     ["y"] = require("telescope-undo.actions").yank_additions,
                --     ["Y"] = require("telescope-undo.actions").yank_deletions,
                --     ["u"] = require("telescope-undo.actions").restore,
                -- },
            },
        },
    },
})
require("telescope").load_extension("undo")
