require("mini.move").setup({
    mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left       = "<S-left>",
        right      = "<S-right>",
        down       = "<S-down>",
        up         = "<S-up>",
        -- Move current line in Normal mode
        line_left  = "",
        line_right = "",
        line_down  = "",
        line_up    = "",
    },
    -- Options which control moving behavior
    options = {
        -- Automatically reindent selection during linewise vertical move
        reindent_linewise = false,
    },
})
