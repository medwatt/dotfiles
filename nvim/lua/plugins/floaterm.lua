-- vim:fdm=marker

-- config {{{
vim.g.floaterm_width = 0.35
vim.g.floaterm_height = 0.35

-- vim.g.floaterm_borderchars = '        '
vim.g.floaterm_wintype = 'floaterm' -- float, split, vsplit

vim.api.nvim_set_hl(0, "Floaterm", { link = "Normal" })
vim.api.nvim_set_hl(0, "FloatermBorder", { link = "FloatBorder" })

-- If wintype is split/vsplit: 'leftabove', 'aboveleft', 'rightbelow', 'belowright', 'topleft', 'botright'. Default: 'botright'.
-- If wintype is float: 'top', 'bottom', 'left', 'right', 'topleft', 'topright', 'bottomleft', 'bottomright', 'center', 'auto'(at the cursor place). Default: 'center'
vim.g.floaterm_position = 'botright'

vim.g.floaterm_opener = 'edit'

vim.g.floaterm_autoclose = 1 -- 0: do not close, 2: always close
-- }}}

-- }}}
