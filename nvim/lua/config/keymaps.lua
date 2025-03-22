-- imports <<<
local _, wk = pcall(require, "which-key")
-- >>>

-- variables <<<
local map = vim.keymap.set
-- >>>

-- func: diagnostics handling<<<
local function ToggleDiagnostics()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled(), {bufnr = bufnr})
end

local function ToggleVirtualText()
    vim.diagnostic.config({
        virtual_text = not vim.diagnostic.config().virtual_text
    })
end
-- >>>

-- func: finder <<<
local function list_buffers()
    require("fzf-lua").buffers {
        ignore_current_buffer = true,
        cwd_only = false,
        sort_mru = true,
    }
end

local function find_files(use_file_dir)
    local cwd = use_file_dir and vim.fn.expand("%:p:h") or vim.fn.getcwd()
    require("fzf-lua").files { cwd = cwd }
end

local function open_dir(config)
    require("fzf-lua").files {
        cwd = config.cwd,
        prompt = config.title,
    }
end

local function grep_files(use_file_dir)
    local cwd = use_file_dir and vim.fn.expand("%:p:h") or vim.fn.getcwd()
    require("fzf-lua").live_grep { cwd = cwd }
end

local function grep_string(use_file_dir)
    local cwd = use_file_dir and vim.fn.expand("%:p:h") or vim.fn.getcwd()
    local search_query = vim.fn.input("Grep For > ")
    require("fzf-lua").grep { cwd = cwd, search = search_query }
end

-- >>>

-- func: handle floating terminals <<<
local term = {}
local float_present = false

local function generate_config(kind, key, title)
    local base_config = {
        position = 'botright',
        cwd = vim.fn.expand('%:p:h'),
        name = key,
        title = title
    }

    local specific_config = {
        ['float'] = { position = 'center', wintype = 'float', width = 0.95, height = 0.95 },
        ['split'] = { wintype = 'split', height = 0.35 },
        ['vsplit'] = { wintype = 'vsplit', height = 0.5 }
    }

    for k, v in pairs(specific_config[kind] or {}) do
        base_config[k] = v
    end

    return base_config
end

local function open_floaterm_helper(key, cmd, title, kind)
    local config = generate_config(kind, key, title)
    term[key] = vim.fn['floaterm#new'](false, cmd, { null = "null" }, config)

    if kind == 'float' then
        float_present = true
    end
end

local function open_floaterm(cmd, title, kind)
    local key = cmd == "" and "new_split" or cmd
    if not term[key] then
        require("lazy").load({ plugins = { "vim-floaterm" } })
        open_floaterm_helper(key, cmd, title, kind)
    else
        if vim.fn.bufnr(term[key]) ~= -1 then -- check if the terminal was closed
            float_present = not float_present
            vim.cmd("FloatermToggle " .. key)
        else
            open_floaterm_helper(key, cmd, title, kind)
        end
    end
end
-- >>>

-- func: preview lsp definiton <<<
local lsp_floating_window = {border = "rounded", max_width = 100}

local function preview_definition()
    local clients = vim.lsp.get_clients()
    if not clients or vim.tbl_isempty(clients) then
        vim.notify("No active LSP client")
        return
    end
    local client = clients[1]
    local params = vim.lsp.utils.make_position_params(nil, client.offset_encoding)
    vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
        if err then
            vim.notify("Error: " .. err.message)
            return
        end
        if not result or vim.tbl_isempty(result) then
            vim.notify("Definition not found")
            return
        end

        local def = result[1]
        local uri = def.uri or def.targetUri
        local range = def.range or def.targetRange
        if not uri or not range then
            vim.notify("Invalid definition result")
            return
        end

        local bufnr = vim.uri_to_bufnr(uri)
        if not vim.api.nvim_buf_is_loaded(bufnr) then
            vim.fn.bufload(bufnr)
        end

        local start_line = range.start.line
        local end_line = range["end"].line
        local context_after = 10
        local total_lines = vim.api.nvim_buf_line_count(bufnr)
        local preview_start = start_line
        local preview_end = math.min(total_lines - 1, end_line + context_after)
        local lines = vim.api.nvim_buf_get_lines(bufnr, preview_start, preview_end + 1, false)
        if #lines == 0 then
            lines = {"No content"}
        end

        local indent = lines[1]:match("^(%s+)")
        if indent then
            local indent_len = #indent
            for i, line in ipairs(lines) do
                if line:sub(1, indent_len) == indent then
                    lines[i] = line:sub(indent_len + 1)
                end
            end
        end

        vim.lsp.utils.open_floating_preview(
            lines,
            vim.api.nvim_buf_get_option(bufnr, "filetype"),
            lsp_floating_window
        )
    end)
end
-- >>>

-- func: debugging <<<
local function StartDap()
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
    if filetype == "lua" then
        require("osv").run_this()
    else
        require("dap").continue()
    end
end

local function TerminateDap()
    require('dapui').close()
    require('dap').repl.close()
    require('dap').terminate()
end
-- >>>

-- commonly-visited directories <<<
local directories = {
    ["n"] = { path = "~/.config/nvim/lua", desc = "neovim"},
    ["c"] = { path = "~/.dot/config", desc = "~/.config"},
    ["l"] = { path = "~/.local", desc = "~/.local"},
    ["3"] = { path = "~/.config/i3", desc = "i3 config"},
    ["g"] = { path = "~/git", desc = "git"},
}

-- >>>

-- key definitions <<<
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

wk.add({
    { "<space>.",   group = "browse directory" },
    { "<space>.n",  group = "neovim" },
    { "<space>,",   group = "navigate directory" },
    { "<space>b",   group = "buffer" },
    { "<space>c",   group = "code" },
    { "<space>bd",  group = "delete" },
    { "<space>d",   group = "delete" },
    { "<space>f",   group = "find" },
    { "<space>g",   group = "git" },
    { "<space>h",   group = "help" },
    { "<space>l",   group = "lsp" },
    { "<space>p",   group = "project" },
    { "<space>,n",  group = "neovim" },
    { "<space>t",   group = "terminal" },
    { "<space>q",   group = "quit" },
    { "<space>r",   group = "repl" },

    { "<leader>",  group = "<leader>" },
    { "<leader>n", group = "neogen" },

    { "<localleader>",   group = "\\" },
    { "<localleader>c",  group = "multicursor" },
    { "<localleader>m",  group = "markdown" },
    { "<localleader>mh", group = "html" },
    { "<localleader>mp", group = "pdf" },
    { "<localleader>l",  group = "latex" },

    { "/",  group = "/" },
    { "/d", group = "delete" },

    { "y",  group = "toggle" },
    { "yo", group = "buffer" },
    { "yd", group = "diagnostics" },
})

-- >>>

-- general <<<
-- Send deleted strings to the black hole register
map('n', 'cc', '"_S')
map('n', 'dd', '"_dd')
map('x', 'p', '"_dP')
map({ 'n', 'x' }, 'c', '"_c')
map({ 'n', 'x' }, 'C', '"_C')
map({ 'n', 'x' }, 'd', '"_d')
map({ 'n', 'x' }, 'D', '"_D')
-- map({'n', 'x'}, 's', '"_s')
-- map({'n', 'x'}, 'S', '"_S')
-- map({'n', 'x'}, 'x', '"_x')
-- map({'n', 'x'}, 'X', '"_X')

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

map("n", [[<ESC>]], [[<ESC><cmd>noh<CR>]])         -- remove highlight after search
map("n", [[<TAB>]], [[<cmd>bn<CR>]])               -- next buffer
map("n", [[<S-TAB>]], [[<cmd>bp<CR>]])             -- previous buffer
map("x", [[<]], [[<gv]])                           -- Move block 1 tab to the left
map("x", [[>]], [[>gv]])                           -- Move block 1 tab to the right

map("n", [[<C-a>]], [[ggVG]])                      -- select all
map("n", [[<C-s>]], [[<cmd>w<CR>]])                -- save
map("i", [[<C-l>]], [[<c-g>u<Esc>[s1z=`]a<c-g>u]]) -- correct spelling
map("n", [[<C-tab>]], [[<C-^>]])                   -- switch to last visted buffer

-- Navigate open windows
map("n", "<M-left>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<M-right>", "<C-w>l", { desc = "Go to right window", remap = true })
map("n", "<M-up>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<M-down>", "<C-w>j", { desc = "Go to lower window", remap = true })

-- Navigate in terminal
map("t", "<M-ESC>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<M-left>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<M-down>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<M-up>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<M-right>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Clear terminal
-- map("t", "<A-l>", "<C-l>")

-- Paste visual text below or up
map("x", [[<m-up>]], [[:yank<CR> '[Pgv]])
map("x", [[<m-down>]], [[:yank<CR> ']pgv]])

-- Open stuff
-- map("n", [[-]], function() vim.cmd("NnnPicker cmd=nnn " .. vim.fn.expand('%:p:h')) end)
map("n", [[<M-s>]], [[<cmd>Alpha<CR>]])
map({ "n", "t" }, [[<M-g>]], function() open_floaterm("lazygit", "lazygit", "float") end)
map({ "n", "t" }, [[<M-n>]], function() open_floaterm("nnn", "nnn", "float") end)
map({ "n", "t" }, [[<M-t>]], function() open_floaterm("", "", "split") end)

-- oil --
-- map("n", [[-]], "<cmd>Oil<cr>", { desc = "open file manager" })
-- map("n", "<space>onn", "<cmd>Oil ~/.config/nvim <cr>", { desc = "nvim config directory" })
-- map("n", "<space>onp", "<cmd>Oil ~/.config/nvim/lua/plugins<cr>", { desc = "nvim plugins config dir" })
-- map("n", "<space>oc", "<cmd>Oil ~/.config/nvim/lua/plugins<cr>", { desc = "config dir" })

-- mini.files--
map("n", [[-]],
    function()
        if not require("mini.files").close() then
            require("mini.files").open(vim.fn.expand("%:p:h"))
        end
    end,
    { desc = "open file manager" }
)

for key, val in pairs(directories) do
    map("n", "<space>," .. key, function() require("mini.files").open(val.path) end, { desc = val.desc })
end

-- hop --
map({ "n", "x", "o" }, [[s]], function() require 'hop'.hint_words() end)
-- map({ "n", "x", "o" }, [[s]], function() require 'hop'.hint_patterns() end)
map({ "n", "x", "o" }, [[S]], function() require 'hop'.hint_words({ current_line_only = true }) end)

-- jaq --
map("n", [[<F8>]], [[<cmd>Jaq<cr>]])

-- easy align --
map("x", [[ga]], [[<plug>(LiveEasyAlign)]])

-- neogen --
map("n", "<leader>nf", "<cmd>Neogen func<CR>")
map("n", "<leader>nc", "<cmd>Neogen class<CR>")

-- multicursors
map("n", "<m-esc>", function() require("multicursor-nvim").clearCursors() end, {desc = "clear multicursors"})
map("n", "<s-up>", function() require("multicursor-nvim").lineAddCursor(-1) end, {desc = "add cursor up"})
map("n", "<s-down>", function() require("multicursor-nvim").lineAddCursor(1) end, {desc = "add cursor down"})
map("n", "<c-s-up>", function() require("multicursor-nvim").matchAddCursor(-1) end, {desc = "add cursor down by matching word"})
map("n", "<c-s-down>", function() require("multicursor-nvim").matchAddCursor(1) end, {desc = "add cursor up by matching word"})
map("n", "<c-leftmouse>", function() require("multicursor-nvim").handleMouse() end, {desc = "add and remove cursors with control + left click"})
map({"n", "v"}, "<s-right>", function() require("multicursor-nvim").nextCursor() end, {desc = "move to right cursor"})
map({"n", "v"}, "<s-left>", function() require("multicursor-nvim").prevCursor() end, {desc = "move to left cursor"})
map({"n", "v"}, "<S-delete>", function() require("multicursor-nvim").deleteCursor() end, {desc = "delete cursor"})
map({"n", "v"}, "<localleader>ca", function() require("multicursor-nvim").alignCursors() end, { desc = "multicursor align" })
map("v", "<localleader>cs", function() require("multicursor-nvim").splitCursors() end, {desc = "split selection into cursors by regex"})

-- diagnostics
map("n", "]d", vim.diagnostic.goto_next)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end)
map("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end)
map("n", "<leader>d", function() vim.diagnostic.open_float(nil, { focus = false }) end, {desc = "open diagnostic" })

-- debug
map("n", "<F5>", function() StartDap() end, {desc = "Start debugging" })
map("n", "<F10>", function() require("dap").step_out() end, {desc = "Step out" })
map("n", "<F11>", function() require("dap").step_into() end, {desc = "Step into" })
map("n", "<F12>", function() require("dap").step_over() end, {desc = "Step over" })

map("n", "K", function()
    if require("dap").session() ~= nil then
        require("dapui").eval()
    else
        vim.lsp.buf.hover(lsp_floating_window)
    end
end, { desc = "Evaluate or Hover" })

-- jump and changes list
map("n", "<leader>j", function() require("fzf-lua").jumps() end, {desc = "view jump list" })
map("n", "<leader>c", function() require("fzf-lua").changes() end, {desc = "view change list" })
map("n", "<leader>z", function() require("utils.window_control").max_win_toggle() end, {desc = "maximize window" })

-- >>>

-- foward slash <<<
map({ "n", "x" }, [[//]], [[/\v]], { desc = "find" })
map("n", [[/']], [[:%s/\v]], { desc = "find and replace" })
map("x", [[/']], [[:s/\%V\v]], { desc = "find and replace" })
map("n", [[/m]], [[<cmd>CopyMatches<CR>]], { desc = "copy matches" })
map("n", [[/l]], [[<cmd>CopyLines<CR>]], { desc = "copy lines" })
map("n", [[/d/]], [[:call histdel('/') | wshada!<CR>]], { desc = "delete search history" })
map("n", [[/d:]], [[:call histdel(':') | wshada!<CR>]], { desc = "delete command history" })
-- >>>

-- toggle options <<<
map("n", "yoc", "<cmd>setlocal cursorline!<Bar>set cul?<CR>", { desc = "cursor line" })
map("n", "yod", "<cmd>set autochdir!<CR>", { desc = "autochdir" })
map("n", "yon", "<cmd>setlocal number!<Bar>set nu?<CR>", { desc = "numbers" })
map("n", "yor", "<cmd>setlocal relativenumber!<Bar>set rnu?<CR>", { desc = "relative numbers" })
map("n", "yos", "<cmd>setlocal spell!<Bar>set spell?<CR>", { desc = "spelling" })
map("n", "yow", "<cmd>setlocal wrap!<Bar>set wrap?<CR>", { desc = "wrap" })
map("n", "yol", "<cmd>setlocal list!<Bar>set list?<CR>", { desc = "list" })
map("n", "yo|", "<cmd>setlocal cursorcolumn!<Bar>set cuc?<CR>", { desc = "cursor column" })

map("n", "ydd", ToggleDiagnostics, { desc = "diagnostics" })
map("n", "ydv", ToggleVirtualText, { desc = "virtual text" })
-- >>>

-- space <<<
for key, val in pairs(directories) do
    local last_dir = val.path:match(".*/(.*)") or 'Root'
    map("n", "<space>." .. key, function() open_dir { cwd = val.path, title = last_dir } end, { desc = val.desc })
end

map("n", "<Space><Space>", function() find_files(true) end, { desc = "browse files" })
map("n", "<Space>;", "<cmd>e ~/.config/nvim/init.lua<CR>", { desc = "open init.lua" })
-- >>>

-- buffer <<<
map("n", "<space>bda", function() require("utils.window_control").delete_buffers("all") end, { desc = "delete all buffers" })
map("n", "<space>bdc", function() require("utils.window_control").delete_buffers("all_except_active") end, { desc = "delete all buffers except active one" })
map("n", "<space>bdd", function() require("utils.window_control").delete_buffers("active") end, { desc = "delete active buffer" })

map("n", "<space>bwa", "<cmd>wa<CR>", { desc = "write all buffers" })
map("n", "<space>bww", "<cmd>w<CR>", { desc = "write buffer" })

map("n", "<space>bs", "<cmd>w <Bar> source %<CR>", { desc = "source buffer" })
map("n", "<space>bf", "<cmd>FormatWrite<CR>", { desc = "format buffer" })

map("n", "<space>bl", function() list_buffers() end, { desc = "list all buffers" })
map("n", "<leader><leader>", function() list_buffers() end, { desc = "list all buffers" })
-- >>>

-- debug <<<
map("n", "<space>db", function() require "dap".toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
map("n", "<space>dB", function() require "dap".set_breakpoint(vim.fn.input "[Condition] > ") end, { desc = "Conditional Breakpoint" })
map("n", "<space>dz", function() require "dap".clear_breakpoints() end, { desc = "Clear Breakpoints" })
map("n", "<space>dc", function() require "dap".continue() end, { desc = "Continue" })
map("n", "<space>dC", function() require "dap".run_to_cursor() end, { desc = "Run to Cursor" })
map("n", "<space>di", function() require "dap".step_into() end, { desc = "Step Into" })
map("n", "<space>do", function() require "dap".step_over() end, { desc = "Step Over" })
map("n", "<space>dO", function() require "dap".step_out() end, { desc = "Step Out" })
map("n", "<space>de", function() require "dapui".eval() end, { desc = "Evaluate" })
map("n", "<space>dE", function() require "dapui".eval(vim.fn.input "[Expression] > ") end, { desc = "Evaluate Input" })
map("n", "<space>dp", function() require "dap".pause.toggle() end, { desc = "Pause" })
map("n", "<space>dq", function() TerminateDap() end, { desc = "Quit" })
map("n", "<space>du", function() require "dapui".toggle() end, { desc = "Toggle UI" })
-- >>>

-- find <<<
map("n", "<space>fg", function() grep_files(true) end, { desc = "live grep" })
map("n", "<space>fG", function() grep_string(true) end, { desc = "grep string" })
map("n", "<space>fb", function() require("fzf-lua").grep_curbuf() end, { desc = "buffer" })
map("n", "<space>fs", function() require("fzf-lua").lsp_document_symbols() end, { desc = "goto symbol" })
map("n", "<space>fh", function() require("fzf-lua").command_history() end, { desc = "command history" })
map("n", "<space>fm", function() require("fzf-lua").marks() end, { desc = "jump to mark" })
map("n", "<space>fr", function() require('spectre').open() end, { desc = "replace (spectre)" })
-- >>>

-- help <<<
map("n", "<space>ha", function() require("fzf-lua").autocmds() end, { desc = "auto commands" })
map("n", "<space>hc", function() require("fzf-lua").colorschemes() end, { desc = "colorscheme" })
map("n", "<space>hC", function() require("fzf-lua").commands() end, { desc = "commands" })
map("n", "<space>hf", function() require("fzf-lua").filetypes() end, { desc = "file types" })
map("n", "<space>hh", function() require("fzf-lua").help_tags() end, { desc = "help pages" })
map("n", "<space>hk", function() require("fzf-lua").keymaps() end, { desc = "keymaps" })
map("n", "<space>hm", function() require("fzf-lua").man_pages() end, { desc = "man pages" })
map("n", "<space>ho", function() require("fzf-lua").options() end, { desc = "options" })
map("n", "<space>hs", function() require("fzf-lua").highlights() end, { desc = "search highlight groups" })
-- >>>

-- git <<<
map("n", "<space>gc", function() require("fzf-lua").git_commits() end, { desc = "commits" })
map("n", "<space>gb", function() require("fzf-lua").git_branches() end, { desc = "branches" })
map("n", "<space>gs", function() require("fzf-lua").git_stash() end, { desc = "status" })
map("n", "<space>gh", "<Cmd>DiffviewFileHistory %<CR>", { desc = "file history" })
map("n", "<space>gd", "<Cmd>DiffviewOpen<CR>", { desc = "diff view open" })
map("n", "<space>gx", "<Cmd>DiffviewClose<CR>", { desc = "diff view close" })
-- >>>

-- lsp <<<
map("n", "<space>la", vim.lsp.buf.code_action, { desc = "code action" })
map("n", "<space>lc", function() print(vim.inspect(vim.lsp.get_clients()[1].server_capabilities)) end, { desc = "server capabilities" })
map("n", "<space>ld", vim.lsp.buf.definition, { desc = "definition" })
map("n", "<space>lD", vim.lsp.buf.declaration, { desc = "declaration" })
map("n", "<space>le", vim.diagnostic.open_float, { desc = "line diagnostics" })
map({"n", "v"}, "<space>lf", function() vim.lsp.buf.format { async = true } end, { desc = "formatting" })
map("n", "<space>lh", function() vim.lsp.buf.hover(lsp_floating_window) end, { desc = "hover" })
-- map("n", "K", function() vim.lsp.buf.hover(lsp_floating_window) end, { desc = "hover" })
map("n", "<space>li", vim.lsp.buf.implementation, { desc = "goto implementation" })
map("n", "<space>lI", vim.cmd.LspInfo, { desc = "lsp info" })
map("n", "<space>ll", vim.diagnostic.setloclist, { desc = "list all diagnostics" })
map("n", "<space>lr", vim.lsp.buf.rename, { desc = "rename" })
map("n", "<space>lR", vim.lsp.buf.references, { desc = "references" })
map("n", "<space>ls", function() vim.lsp.buf.signature_help(lsp_floating_window) end, { desc = "signature help" })
map("n", "<C-k>", function() vim.lsp.buf.signature_help(lsp_floating_window) end, { desc = "signature help" })
map("n", "<space>lt", vim.lsp.buf.type_definition, { desc = "goto type definition" })
map("n", "<space>lx", function() require('plugins.lsp').toggle_lsp() end, { desc = "toggle lsp signs" })
map("n", "<space>lp", preview_definition, { desc = "preview definition" })

-- >>>

-- project <<<
map("n", "<space>pa", function() require('utils.project').add_project() end, { desc = "add project to list" })
map("n", "<space>pc", function() require('utils.project').set_project_to_cwd() end, { desc = "set project root to file path" })
map("n", "<space>pe", function() require('utils.project').edit_projects_list() end, { desc = "edit projects list" })
map("n", "<space>pf", function() require('utils.project').project_files() end, { desc = "find files" })
map("n", "<space>pg", function() require('utils.project').project_live_grep() end, { desc = "live grep" })
map("n", "<space>pG", function() require('utils.project').project_grep(vim.fn.input("Grep For > ")) end, { desc = "grep string" })
map("n", "<space>pr", function() require('utils.project').project_search_and_replace() end, { desc = "search and replace" })
map("n", "<space>ps", function() require('utils.project').switch_project() end, { desc = "switch project" })
map("n", "<space>px", function() require('utils.project').close_non_project_buffers() end, { desc = "close non-project buffers" })
-- >>>

-- repl <<<
map("n", "<space>ro", "<cmd>REPLStart<CR>", { desc = "open REPL" })
map("n", "<space>rb", "<cmd>REPLSendBlock<CR>", { desc = "send code block" })
-- map("n", "<S-CR>", "<cmd>REPLSendBlock<CR>", { desc = "send code block" })
-- map("x", "<S-CR>", "<cmd>REPLSendVisual<CR>", { desc = "send visual block" })
-- map("n", "<C-CR>", "<cmd>REPLSendLine<CR>", { desc = "send code line" })
map("n", "<space>rl", "<cmd>REPLSendLine<CR>", { desc = "send code line" })
map("n", "<space>rv", "<cmd>REPLSendVisual<CR>", { desc = "send visual block" })
map({"n","t"}, "<M-r>", "<cmd>REPLHideOrFocus<CR>", { desc = "toggle" })

-- >>>

-- terminal <<<
map("n", "<space>tv", function() open_floaterm("", "", "vsplit") end, { desc = "open vertical terminal" })
map("n", "<space>th", function() open_floaterm("", "", "split") end, { desc = "open horizontal terminal" })
map("n", "<space>tf", function() open_floaterm("", "", "float") end, { desc = "open floating terminal" })
-- >>>

-- quit <<<
local last_session = vim.fn.stdpath("data") .. "/state/session/last"
map("n", "<space>qc", function() vim.cmd("cd " .. vim.fn.expand("%:p:h")) end, { desc = "set root directory" })
map("n", "<space>qd", ":SDelete!", { desc = "delete session", silent = false })
map("n", "<space>qq", "<cmd>qa!<CR>", { desc = "quit without saving" })
map("n", "<space>qr", "<cmd>source " .. last_session .. "<CR>", { desc = "restore last session" })
map("n", "<space>qs", "<cmd>mksession! " .. last_session .. "<CR>", { desc = "quick save current session" })
map("n", "<space>qS", "lua SaveSession()", { desc = "save session to file", silent = false })
map("n", "<space>qR", "lua LoadSession()", { desc = "restore session from file", silent = false })
-- >>>

