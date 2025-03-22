vim.cmd('hi clear')
if vim.fn.exists('syntax_on') then
	vim.cmd('syntax reset')
end

vim.g['colors_name'] = 'morning_star'

package.loaded['morning_star'] = nil

require('morning_star').setup()
