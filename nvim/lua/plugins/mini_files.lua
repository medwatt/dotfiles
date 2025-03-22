local mini = require('mini.files')

mini.setup(
-- No need to copy this inside `setup()`. Will be used automatically.
{
    -- Customization of shown content
    content = {
        -- Predicate for which file system entries to show
        filter = nil,
        -- What prefix to show to the left of file system entry
        prefix = nil,
        -- In which order to show file system entries
        sort = nil,
    },

    -- Module mappings created only inside explorer.
    -- Use `''` (empty string) to not create one.
    mappings = {
        close       = 'q',
        go_in       = '',
        go_in_plus  = '<Enter>',
        go_out      = '<BS>',
        go_out_plus = '',
        mark_goto   = "`",
        mark_set    = 'm',
        reset       = 'S',
        show_help   = 'g?',
        synchronize = '<C-S>',
    },

    -- General options
    options = {
        -- Whether to delete permanently or move into module-specific trash
        permanent_delete = true,
        -- Whether to use for editing directories
        use_as_default_explorer = true,
    },

    -- Customization of explorer windows
    windows = {
        -- Maximum number of windows to show side by side
        max_number = 1,
        -- Whether to show preview of file/directory under cursor
        preview = false,
        -- Width of focused window
        width_focus = vim.o.columns,
        -- Width of non-focused window
        width_nofocus = 15,
        -- Width of preview window
        width_preview = 25,
    },
})

-- local default_height = vim.o.lines - vim.o.cmdheight - 3
-- local default_width = vim.o.columns

vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesWindowUpdate',
    callback = function(args)
        local config = vim.api.nvim_win_get_config(args.data.win_id)

        -- Ensure fixed height
        config.height = vim.o.lines - vim.o.cmdheight - 3
        -- config.width = default_width
        config.width = vim.o.columns

        -- Ensure title padding
        if config.title[#config.title][1] ~= ' ' then
            table.insert(config.title, { ' ', 'NormalFloat' })
        end
        if config.title[1][1] ~= ' ' then
            table.insert(config.title, 1, { ' ', 'NormalFloat' })
        end

        vim.api.nvim_win_set_config(args.data.win_id, config)
    end,
})

vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(args) vim.keymap.set("n", "l",
                    function()
                        local path = mini.get_fs_entry().path
                        vim.fn.setreg("+", path)
                    end,
                    { buffer = args.data.buf_id })
                end,
})
