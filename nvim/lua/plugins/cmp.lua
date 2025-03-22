local _, cmp = pcall(require, "cmp")
-- local _, cmp_ultisnips_mappings = pcall(require, "cmp_nvim_ultisnips.mappings")


local kind_icons = {
    Text = "   ",
    Method = "  ",
    Function = "  ",
    Constructor = "  ",
    Field = " ﴲ ",
    Variable = "  ",
    Class = "  ",
    Interface = " ﰮ ",
    Module = "  ",
    Property = " ﰠ ",
    Unit = "  ",
    Value = "  ",
    Enum = " 練",
    Keyword = "  ",
    Snippet = "  ",
    Color = "  ",
    File = "  ",
    Reference = "  ",
    Folder = "  ",
    EnumMember = "  ",
    Constant = " ﲀ ",
    Struct = " ﳤ ",
    Event = "  ",
    Operator = "  ",
    TypeParameter = "  ",
}

local function get_kind_icon(kind_type)
    return kind_icons[kind_type]
end

cmp.setup({

    completion = {
        -- completeopt = "menu,menuone,preview,noinsert",
        completeopt = "menuone,noselect",

    },

    formatting = {
        format = function(entry, item)
            item.kind = string.format("%s %s", get_kind_icon(item.kind), item.kind)
            item.menu = ({
                nvim_lsp = "[LSP]",
                -- ultisnips = "[Snp]",
                -- luasnip = "[Snp]",
                -- nvim_lua = "[Lua]",
                path = "[Path]",
                buffer = "[Buf]",
                omni = "[Omni]",
            })[entry.source.name]
            item.dup = ({
                buffer = 1,
                path = 1,
                nvim_lsp = 0,
            })[entry.source.name] or 0
            return item
        end,
    },

    snippet = {
        expand = function(args)
            require 'luasnip'.lsp_expand(args.body)
        end
    },

    -- snippet = {
        --     expand = function(args)
            --         vim.fn["UltiSnips#Anon"](args.body)
            --     end,
            -- },

    sources = {
        { name = "nvim_lsp" },
        -- { name = "ultisnips", keyword_length = 2 },
        -- { name = "luasnip", keyword_length = 2 },
        { name = "buffer", keyword_length = 4 },
        { name = 'nvim_lsp_signature_help' },
        -- { name = "omni" },
        { name = "path" },
        { name = "nvim_lua" },
        -- more sources
    },

    mapping = {

        ["<Up>"] = cmp.mapping.select_prev_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),

        ["<Down>"] = cmp.mapping.select_next_item(),
        ["<Tab>"] = cmp.mapping.select_next_item(),

        ['<C-Space>'] = cmp.mapping.complete(),

        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        }),

        ["<C-e>"] = cmp.mapping.close(),
    },

})
