-- imports <<<
require("mason").setup()

local lspconfig = require("lspconfig")

require("mason-lspconfig").setup({
    ensure_installed = {
        "vimls",
        "bashls",
        "lua_ls",
        "texlab",
    },
})
-- >>>

local M = {}

require "lspconfig".vimls.setup {}

require "lspconfig".bashls.setup {}

require "lspconfig".clangd.setup {
    cmd = {
        "clangd",
        "--fallback-style=LLVM",
    },
}

require("lspconfig")["tinymist"].setup {
    settings = {
        formatterMode = "typstyle",
        exportPdf = "onType",
        semanticTokens = "disable"
    }
}

-- texlab <<<
lspconfig.texlab.setup {
settings = {
texlab = {
auxDirectory = ".",
bibtexFormatter = "texlab",
build = {
    args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
    executable = "latexmk",
    forwardSearchAfter = false,
    onSave = false
},
chktex = {
    onEdit = false,
    onOpenAndSave = false
},
diagnostics = {
    ignoredPatterns = { [[\\hbox]] },
},
diagnosticsDelay = 300,
formatterLineLength = 80,
forwardSearch = {
    args = {}
},
            latexFormatter = "latexindent",
            latexindent = {
                modifyLineBreaks = true,
                ["local"] = os.getenv("HOME") .. "/.config/nvim/lua/plugins/latexindent/settings.yaml",
            }
        }
    }
}
-- >>>

-- lua_ls <<<
-- lspconfig.lua_ls.setup {
--     on_init = function(client)
--         local path = client.workspace_folders[1].name
--         if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
--             client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
--                 Lua = {
--                     runtime = {
--                         version = "LuaJIT"
--                     },
--
--                     diagnostics = {
--                         enable = true,
--                         globals = { "vim", "use", "s", "sn", "i", "rep", "c", "d", "f", "t", "fmta", "fmt" },
--                         ignoredFiles = "Opened",
--                         -- disable = {"lowercase-global"},
--                         workspaceEvent = "None",
--                         workspaceDelay = 1000000,
--                     },
--
--                     semantic = {
--                         enable = false,
--                         variable = false,
--                         annotation = false,
--                     },
--
--                     signatureHelp = {
--                         enable = false,
--                     },
--
--                     format = {
--                         enable = true,
--                     },
--
--                     telemetry = {
--                         enable = false,
--                     },
--
--                     completion = {
--                         enable = false
--                     },
--                     -- Make the server aware of Neovim runtime files
--                     workspace = {
--                         maxPreload = 10,
--                         preloadFileSize = 10,
--                         checkThirdParty = false,
--                         library = {
--                             vim.env.VIMRUNTIME,
--                             -- "${3rd}/luv/library"
--                             -- "${3rd}/busted/library",
--                         },
--                         ignoreDir = { "*/" },
--                         -- or pull in all of "runtimepath". NOTE: this is a lot slower
--                         -- library = vim.api.nvim_get_runtime_file("", true)
--                     }
--                 }
--             })
--             client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
--         end
--         return true
--     end
-- }
lspconfig.lua_ls.setup {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.uv.fs_stat(path.."/.luarc.json") or vim.uv.fs_stat(path.."/.luarc.jsonc") then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you"re using
                -- (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT"
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME
                    -- Depending on the usage, you might want to add additional paths here.
                    -- "${3rd}/luv/library"
                    -- "${3rd}/busted/library",
                }
                -- or pull in all of "runtimepath". NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
                -- library = vim.api.nvim_get_runtime_file("", true)
            }
        })
    end,
    settings = {
        Lua = {
            diagnostics = {
                enable = true,
                globals = { "vim", "use", "s", "sn", "i", "rep", "c", "d", "f", "t", "fmta", "fmt" },
            },
        }
    }
}
-- >>>

-- python <<<

-- pyright <<<
local function load_pyright ()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

    require("lspconfig").pyright.setup {

        capabilities = capabilities,

        settings = {
            pyright = {
                -- Using Ruff"s import organizer
                disableOrganizeImports = true,
            },
            python = {
                analysis = {
                    diagnosticMode = "openFilesOnly",
                    useLibraryCodeForTypes = true,
                    stubPath = "~/miniforge3/typings",
                    typeCheckingMode = "all",
                    reportMissingTypeStubs = true,
                    diagnosticSeverityOverrides = {
                        -- reportUnusedImport = false,
                    },
                    -- Ignore all files for analysis to exclusively use Ruff for linting
                    -- ignore = { "*" },
                },
            },
        },
    }
end
-- >>>

-- basedpyright <<<
local function load_basedpyright ()
    require("lspconfig").basedpyright.setup {
        settings = {
            basedpyright = {
                analysis = {
                    diagnosticMode = "openFilesOnly",
                    typeCheckingMode = "standard",
                    diagnosticSeverityOverrides = {
                        reportUninitializedInstanceVariable = false,
                    },

                }
            }
        }
    }
end


-- >>>

-- pylsp <<<
local function load_pylsp ()
    require("lspconfig").pylsp.setup {
        settings = {
            pylsp = {
                plugins = {
                    pycodestyle = {
                        enabled = true, -- too much warning
                        -- ignore = { "E231", "E226", "E306", "E305" },
                        maxLineLength = 9999,
                    }
                }
            }
        }
    }
end
-- >>>

-- ruff <<<
local function load_ruff ()

    local on_attach = function(client, bufnr)
        if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end
    end

    require("lspconfig").ruff.setup {
        on_attach = on_attach,
        init_options = {
            settings = {
                -- Any extra CLI arguments for `ruff` go here.
                args = {},
            }
        }
    }

    load_pyright()

end
-- >>>

local python_lsps = {
    pyright = load_pyright,
    basedpyright = load_basedpyright,
    ruff = load_ruff,
    pylsp = load_pylsp,
}

python_lsps["ruff"]()

-- >>>

return M
