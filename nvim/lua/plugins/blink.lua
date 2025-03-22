local _, blink = pcall(require, "blink.cmp")

blink.setup({
    keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-space>"] = { "show_documentation", "hide_documentation", "show" },
    },

    appearance = {
        -- Sets the fallback highlight groups to nvim-cmp"s highlight groups
        -- Useful for when your theme doesn"t support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to "mono" for "Nerd Font Mono" or "normal" for "Nerd Font"
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono"
    },

    -- Show documentation when selecting a completion item
    -- documentation = { auto_show = true, auto_show_delay_ms = 500 },

    -- Use a preset for snippets, check the snippets documentation for more information
    snippets = { preset = "luasnip" },

    -- Experimental signature help support
    signature = { enabled = true },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
        default = { "snippets", "lsp", "path", "buffer"},

        -- Disable cmdline completions
        cmdline = {},

        providers = {
            lsp = {
                name = "LSP",
                module = "blink.cmp.sources.lsp",
                opts = {}, -- Passed to the source directly, varies by source

                --- NOTE: All of these options may be functions to get dynamic behavior
                --- See the type definitions for more information
                enabled = true, -- Whether or not to enable the provider
                async = false, -- Whether we should wait for the provider to return before showing the completions
                timeout_ms = 2000, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
                transform_items = nil, -- Function to transform the items before they"re returned
                should_show_items = true, -- Whether or not to show the items
                max_items = nil, -- Maximum number of items to display in the menu
                min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
                -- If this provider returns 0 items, it will fallback to these providers.
                -- If multiple providers falback to the same provider, all of the providers must return 0 items for it to fallback
                fallbacks = {},
                score_offset = 0, -- Boost/penalize the score of the items
                override = nil, -- Override the source"s functions
            }
        }

    },
})
