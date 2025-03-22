-- vim:fdm=marker
local ls = require('luasnip')
local types = require("luasnip.util.types")

local function load_snippets_from_path ()
    require("luasnip.loaders.from_lua").lazy_load({
        paths = {
            "~/.config/nvim/lua/snippets/luasnip/snippets",
            vim.fn.expand('%:p:h') .. "/.luasnippets/"}
        })
end

load_snippets_from_path()
vim.api.nvim_create_user_command('LoadSnippetsPathReload', load_snippets_from_path, {})

require("luasnip").config.set_config({

    -- Keep last snippet to jump back into it
    history = false,

    -- Update changes as you type
    -- updateevents = "TextChanged,TextChangedI",

    -- Enable autotriggered snippets
    enable_autosnippets = true,

    -- Use Tab (or some other key if you prefer) to trigger visual selection
    store_selection_keys = "<C-j>",

    ext_opts = {
        [types.choiceNode] = {
            active = {
                virt_text = { { "●", "Boolean" } },
            },
        },
    },
})

-- keymaps {{{
vim.keymap.set({ "i", "s" }, "<c-j>", function()
    ls.expand()
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-k>", function()
    ls.jump(1)
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-a>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-e>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, { silent = true })
-- }}}
