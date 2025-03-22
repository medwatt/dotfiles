require("bufferline").setup {
    options = {
        mode = "buffers",                        -- set to "tabs" to only show tabpages instead
        numbers = "none",                        -- "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
        close_command = "bdelete! %d",           -- can be a string | function, see "Mouse actions"
        right_mouse_command = "bdelete! %d",     -- can be a string | function, see "Mouse actions"
        left_mouse_command = "buffer %d",        -- can be a string | function, see "Mouse actions"
        middle_mouse_command = nil,              -- can be a string | function, see "Mouse actions"
        indicator = {
            icon = '▎',                          -- this should be omitted if indicator style is not 'icon'
            style = 'icon',                      -- | 'underline' | 'none',
        },
        separator_style = "thin",                -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        max_prefix_length = 15,        -- prefix used when a buffer is de-duplicated
        truncate_names = true,         -- whether or not tab names should be truncated
        tab_size = 18,
        diagnostics = "nvim_lsp",      -- false
        diagnostics_update_in_insert = false,
        sort_by = 'insert_at_end',     -- 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs'
    }
}
