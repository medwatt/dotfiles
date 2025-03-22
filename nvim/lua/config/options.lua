-- vim:fdm=marker

local opt = vim.opt

-- Prevent automatic change to the directory of the current file
opt.autochdir = false

-- Enable automatic writing of files before :next, :make, etc.
opt.autowrite = true

-- use auto-indentation
-- opt.autoindent = true

-- Clipboard behavior for copy-paste functionality
opt.clipboard = 'unnamedplus'

-- enable color column at the 80th character
-- opt.colorcolumn = '80'

-- Hide (conceal) special characters like `` in markdown files
opt.conceallevel = 2

-- change shell from bash to zsh
-- opt.shell = "/usr/bin/zsh"

-- Enable highlighting of the cursor line
opt.cursorline = true

-- Enable highlighting of the cursor column
opt.cursorcolumn = false

-- set height of command line to 0
-- vim.cmdheight = 0

-- Convert tabs to spaces
opt.expandtab = true

-- Add spellcheck options for autocomplete
opt.complete:append("kspell")

-- don't use tags for completion
-- opt.complete:remove("t")

-- Autocomplete settings
opt.completeopt = "menu,menuone,noselect"

-- Specify characters to display in the leftmost column when 'list' is enabled
opt.fillchars = {
    diff = "∙",
    eob = " ",
    fold = "·",
    vert = "┃",
}

-- Enable folding
opt.foldenable = true

-- use expression for folding
vim.o.foldmethod = "marker"
vim.cmd[[set foldmarker=<<<,>>>]]

-- use TreeSitter for folding
-- opt.foldexpr = "nvim_treesitter#foldexpr()"

-- maximum amount of nested folds
-- opt.foldnestmax = 10

-- minimum amount of lines per fold
-- opt.foldminlines = 1

-- start unfolded for fold level
-- opt.foldlevelstart = 0

-- start unfolded for fold level
-- opt.foldlevel = 0

-- Invert the meaning of the /g flag in search and replace
opt.gdefault = true

-- Custom grep program settings
vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"

-- Grep output format
vim.o.grepformat = "%f:%l:%c:%m"

-- Allow hiding buffers with unsaved changes
opt.hidden = true

-- Enable highlighting of search matches
opt.hlsearch = true

-- Enable incremental search highlighting
opt.incsearch = true

-- Enable case-insensitive search
opt.ignorecase = true

-- Character encoding used within Neovim
opt.encoding = 'utf-8'

-- Enable mouse functionality in all modes
opt.mouse = 'a'

-- Enable magic characters for regular expressions
opt.magic = true

-- Popup blend
opt.pumblend = 10

-- Maximum number of entries in a popup
opt.pumheight = 10

-- Lines of context when scrolling
opt.scrolloff = 4

-- Columns of context when scrolling sideways
opt.sidescrolloff = 8

-- Enable case-sensitive search if any uppercase character is present
opt.smartcase = true

-- Time to wait for a mapped sequence to complete in milliseconds
-- opt.timeoutlen = 300

-- Time before CursorHold event is triggered in milliseconds
opt.updatetime = 200

-- Use 4 spaces for indentation
opt.tabstop = 4

-- Use 4 spaces for indentation during automatic indenting
opt.shiftwidth = 4

-- Enable smart indenting
opt.smartindent = false

-- Make tabbing behavior smarter
opt.smarttab = true

-- Enable GUI colors
opt.termguicolors = true

-- Show or hide whitespace characters
opt.list = true

-- Symbols for displaying whitespace characters
opt.listchars = {
    nbsp = "+",
    extends = "→",
    precedes = "←",
    tab = "»·",
    trail = "•",
}

-- Show effects of a command incrementally
opt.inccommand = 'nosplit'

-- Show status line always
opt.laststatus = 2

-- Disable display of the tabline
opt.showtabline = 0

-- Do not show mode in command line
opt.showmode = false

-- Control of the display column for signs
opt.signcolumn = "yes"

-- disable syntax, since we have treesitter
-- opt.syntax = "off"

-- Treat parts of camelCase words as separate words for spell check
opt.spelloptions = "camel"

-- Define spelling dictionaries
opt.spelllang = "en"

-- Enable line numbering
opt.number = true

-- Enable relative line numbering
opt.relativenumber = true

-- Position of horizontal split
opt.splitbelow = true

-- Position of vertical split
opt.splitright = true

-- Undo levels
opt.undolevels = 10000

-- Display options as a list when switching buffers and so on
opt.wildmenu = true

-- Shell-like autocomplete behavior
opt.wildmode = "longest:full,full"

-- Patterns to ignore during file-navigation
opt.wildignore:append("*.o,*.so")

-- Substitute for 'wildchar' (<Tab>) in macros
opt.wildcharm = 26

-- allow going past the end of line in visual block mode
-- opt.virtualedit = "block"

-- indent wrapped lines to match line start
-- opt.breakindent = true

-- Don't position cursor at the start of a line after certain operations
opt.startofline = false

-- Show only one line for lines that exceed the window width
opt.wrap = false

-- Keys that are allowed to cross line boundaries
opt.whichwrap = 'b,h,l,s,<,>,[,],~'

--------------------------------------------------------------------------------
--                                diagnostics                                 --
--------------------------------------------------------------------------------
-- Get a reference to the original virtual_text handler.
local orig_virtual_text_handler = vim.diagnostic.handlers.virtual_text

local function custom_virtual_text_handler(namespace, bufnr, diagnostics, opts)
    -- Limit the diagnostics displayed
    local max_diagnostics = 1
    local limited_diagnostics = {}

    for i = 1, math.min(#diagnostics, max_diagnostics) do
        table.insert(limited_diagnostics, diagnostics[i])
    end

    orig_virtual_text_handler.show(namespace, bufnr, limited_diagnostics, opts)
end

-- Override the default virtual text handler
vim.diagnostic.handlers.virtual_text = {
    virtual_text = {
        prefix = "●",
    },
    show = custom_virtual_text_handler,
    hide = orig_virtual_text_handler.hide,
}

vim.diagnostic.config {
    signs = true,
    underline = false,
    update_in_insert = false,
}

--------------------------------------------------------------------------------
--                            swap, undo, session                             --
--------------------------------------------------------------------------------
local directories = {
    undo = vim.fn.stdpath('data') .. "/state/undo",
    backup = vim.fn.stdpath('data') .. "/state/backup",
    session = vim.fn.stdpath('data') .. "/state/session",
}

for _, dir in pairs(directories) do
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, 'p')
    end
end

opt.swapfile = false
opt.backup = true
opt.undofile = true
opt.backupdir = directories['backup']
opt.undodir = directories['undo']


-- reverse scrolling direction
-- vim.keymap.set('n', '<ScrollWheelLeft>', '<ScrollWheelRight>', {noremap = true})
-- vim.keymap.set('n', '<ScrollWheelRight>', '<ScrollWheelLeft>', {noremap = true})

