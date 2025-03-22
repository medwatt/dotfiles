local _, telescope = pcall(require, 'telescope')
local _, actions = pcall(require, 'telescope.actions')
local _, action_state = pcall(require, 'telescope.actions.state')

------------------------------------------------------------------------
--                          custom function                           --
------------------------------------------------------------------------

local telescope_toggle_mode = function()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "n" then
        vim.cmd [[startinsert]]
        return
    end
    if mode == "i" then
        vim.cmd [[stopinsert]]
        return
    end
end

local telescope_multiopen = function(pb, method)
    local picker = action_state.get_current_picker(pb)
    local multi = picker:get_multi_selection()
    actions.select_default(pb) -- the normal enter behaviour
    for _, j in pairs(multi) do
        if j.path ~= nil then  -- is it a file -> open it as well:
            vim.cmd(string.format("%s %s", method, j.path))
        end
    end
end

local telescope_multi_selection_open_vsplit = function(prompt_bufnr)
    telescope_multiopen(prompt_bufnr, "vsplit")
end
local telescope_multi_selection_open_split = function(prompt_bufnr)
    telescope_multiopen(prompt_bufnr, "split")
end
local telescope_multi_selection_open_tab = function(prompt_bufnr)
    telescope_multiopen(prompt_bufnr, "tabe")
end
local telescope_multi_selection_open = function(prompt_bufnr)
    telescope_multiopen(prompt_bufnr, "edit")
end

-- temporary fix for telescope opening in insert mode
local function stopinsert(callback)
    return function(prompt_bufnr)
        vim.cmd.stopinsert()
        vim.schedule(function()
            callback(prompt_bufnr)
        end)
    end
end

------------------------------------------------------------------------
--                               setup                                --
------------------------------------------------------------------------

telescope.setup {

    defaults = {
        prompt_prefix = " ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        -- file_ignore_patterns = {'.gif', '.pdf'},
        path_display = { "smart" },
        winblend = 0,
        border = {},
        borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        color_devicons = true,
        use_less = true,
        set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                height = 0.9,
                preview_cutoff = 120,
                preview_width = 0.5,
                prompt_position = "top",
                width = 0.8
            },
        },
        mappings = {
            i = {
                ['<CR>'] = stopinsert(telescope_multi_selection_open),
                ['<C-v>'] = telescope_multi_selection_open_vsplit,
                ['<C-s>'] = telescope_multi_selection_open_split,
                ['<C-t>'] = telescope_multi_selection_open_tab,
                -- ["<C-j>"] = actions.move_selection_next,
                -- ["<C-k>"] = actions.move_selection_previous,
                -- ["<C-a>"] = actions.add_selection,
                -- ["<C-r>"] = actions.remove_selection,
                -- ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<ESC>"] = actions.close,
                -- ["<CR>"] = actions.select_default + actions.center,
                ["<M-ESC>"] = telescope_toggle_mode,
            },
            -- n = {
            --     ["<C-j>"] = actions.move_selection_next,
            --     ["<C-k>"] = actions.move_selection_previous,
            --     ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            -- }
        },
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
        },
        file_sorter = require 'telescope.sorters'.get_fuzzy_file,
        generic_sorter = require 'telescope.sorters'.get_generic_fuzzy_sorter,
        file_previewer = require 'telescope.previewers'.vim_buffer_cat.new,
        grep_previewer = require 'telescope.previewers'.vim_buffer_vimgrep.new,
        qflist_previewer = require 'telescope.previewers'.vim_buffer_qflist.new,
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require 'telescope.previewers'.buffer_previewer_maker,
    },
    pickers = {
        find_files = {
            find_command = { "fd", "--type=file", "--hidden"},
        },
        live_grep = {
            only_sort_text = true,
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        }
    },
}

telescope.load_extension('fzf')
