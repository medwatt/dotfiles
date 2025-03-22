-- bootstrap plugin manager <<<
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)
-- >>>

-- variables <<<
local plugin_config = vim.fn.stdpath("config") .. "/lua/plugins/"
-- >>>

-- plugins <<<

-- look and feel <<<
local look_and_feel = {
    {
        "nvim-lualine/lualine.nvim",
        pin = true,
        event = "BufReadPre",
        config = function() require("plugins.lualine") end
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufReadPre",
        config = function() require("plugins.indent_blankline") end
    },

    {
        "NvChad/nvim-colorizer.lua",
        event = "CursorHold",
        config = function() require("colorizer").setup() end
    },
}
-- >>>

-- quality of life <<<

-- terminals <<<
local qol_terminals = {
    {
        "voldikss/vim-floaterm",
        cmd = { "FloatermToggle", "FloatermNew" },
        config = function() require("plugins.floaterm") end
    },
}

-- >>>

-- quality of life <<<
local qol_editing = {
    {
        "junegunn/vim-easy-align",
        keys = {
            { "<plug>(LiveEasyAlign)", mode = "x" },
        },
        config = function() require("plugins.easy_align") end
    },

    {
        'echasnovski/mini.move',
        version = false,
        config = function() require("plugins.mini_move") end,
        keys = {
            { "<s-left>",  mode = "v" },
            { "<s-right>", mode = "v" },
            { "<s-up>",    mode = "v" },
            { "<s-down>",  mode = "v" },
        },
    },

    {
        "kylechui/nvim-surround",
        config = function() require("plugins.surround") end,
        keys = {
            { "gs", mode = { "n", "x" } },
            { "ds", mode = { "n" } },
            { "cs", mode = { "n" } },
        },
    },
}
-- >>>

-- qol general <<<
local qol_general = {
    {
        'echasnovski/mini.files',
        version = '*',
        lazy = true,
        config = function() require("plugins.mini_files") end
    },

    {
        "smoka7/hop.nvim",
        lazy = true,
        config = function() require("hop").setup() end
    },

    {
        "nvim-pack/nvim-spectre",
        lazy = true
    },

    {
        "tpope/vim-repeat",
        event = "CursorHold"
    },

    {
        "jake-stewart/multicursor.nvim",
        lazy = true,
        branch = "1.0",
        dependencies = {"nvim-lua/plenary.nvim"},
        config = function() require("plugins.multicursor") end,
    },

    {
        "sindrets/diffview.nvim",
        cmd = {
            "DiffviewOpen",
            "DiffviewFileHistory",
        },
    },

    {
        "danymat/neogen",
        cmd = { "Neogen" },
        config = function() require("plugins.neogen") end,
    },

    {
        "michaeljsmith/vim-indent-object",
        keys = {
            { "ai", mode = { "o", "x" } },
            { "ii", mode = { "o", "x" } },
        },
    },
}
-- >>>

-- >>>

-- menus <<<
local which_key = {
    "folke/which-key.nvim",
    event = { "CursorHold" },
    config = function()
        require("plugins.which-key")
        require("config.keymaps")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
}

local startup_menu = {
    "goolord/alpha-nvim",
    config = function() require("plugins.alpha-nvim") end
}
-- >>>

-- snippet manager <<<
local snippets = {
    "L3MON4D3/LuaSnip",
    event = { "BufReadPost" },
    build = "make install_jsregexp",
    config = function() require("plugins.luasnip") end,
}
-- >>>

-- text completion <<<
local completion = {
    "hrsh7th/nvim-cmp",
    event = { "BufReadPost" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-omni",
    },
    config = function() require("plugins.cmp") end
}

-- local completion = {
--     "saghen/blink.cmp",
--     version = "*",
--     config = function() require("plugins.blink") end
-- }
-- >>>

-- finder <<<
local fzf_lua = {
    "ibhagwan/fzf-lua",
    event = "CursorHold",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("plugins.fzf-lua") end,
}
-- >>>

-- lsp <<<
local lsp = {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function() require("plugins.lsp") end,
    },

}
-- >>>

-- linter <<<
local linter = {
    "nvimtools/none-ls.nvim",
    event = "CursorHold",
    config = function() require("plugins.null-ls") end
}
-- >>>

-- treesitter <<<
local treesitter = {
    "nvim-treesitter/nvim-treesitter",
    event = "CursorHold",
    config = function() require("plugins.treesitter") end,
    dependencies = {
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            config = function() require("plugins.treesitter_textobjects") end
        }
    },
}
-- >>>

-- debugger <<<
local debugger = {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "thehamsta/nvim-dap-virtual-text",
        "jbyuki/one-small-step-for-vimkind"
    },
    config = function() require("plugins.dap") end
}

-- >>>

-- code runner <<<
local code_runner = {
    {
        "is0n/jaq-nvim",
        cmd = "Jaq",
        config = function() require("plugins.jaq") end
    },
}
-- >>>

-- filetype: markdown <<<
local markdown = {
    {
        "godlygeek/tabular",
        ft = { "markdown", "markdown.pandoc" }
    },

    {
        "OXY2DEV/markview.nvim",
        lazy = true,
        ft = { "markdown", "quarto" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
        config = function() require("plugins.markview") end
    },
}
-- >>>

-- filetypes: latex <<<
local latex = {
    {
        "lervag/vimtex",
        ft = { "tex", "latex", "markdown", "markdown.pandoc" },
        config = function() vim.cmd("source " .. plugin_config .. "vimtex.vim") end
    },
}
-- >>>

-- local plugins <<<
local local_plugins = {
    {
        dir = "~/.config/nvim/local_plugins/doom-one.nvim",
    },
    {
        dir = "/home/medwatt/.config/nvim/local_plugins/yarepl.nvim",
        cmd = "REPLStart",
        config = function() require("plugins.yarepl") end
    },
}
-- >>>

-- >>>

require("lazy").setup(
    {
        look_and_feel,

        qol_terminals,
        qol_editing,
        qol_general,

        latex,
        markdown,

        snippets,
        completion,

        which_key,
        startup_menu,

        fzf_lua,
        treesitter,
        lsp,
        linter,

        debugger,
        code_runner,

        local_plugins,
    },

    require("plugins.lazy") -- lazy plugin manager settings

)

require "config"



