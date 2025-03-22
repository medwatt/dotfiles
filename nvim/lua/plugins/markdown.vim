"----------Markdown-Live-Preview----------"
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 0
let g:mkdp_theme = 'light'
let g:mkdp_preview_options = {
\ 'mkit': {},
\ 'katex': {},
\ 'uml': {},
\ 'maid': {},
\ 'disable_sync_scroll': 0,
\ 'sync_scroll_type': 'middle',
\ 'hide_yaml_meta': 1,
\ 'sequence_diagrams': {},
\ 'flowchart_diagrams': {},
\ 'content_editable': v:false
\ }
let g:mkdp_markdown_css = '/home/medwatt/.config/nvim/pandoc_files/css/pandoc.css'
let g:mkdp_page_title = '「${name}」'

"----------Markdown-Pandoc-Syntax----------"
" let g:pandoc#folding#fdc = 0 " disable fold column
" let g:pandoc#folding#fold_yaml = 1 " fold yaml
" let g:pandoc#folding#folding_yaml = 1
" let g:pandoc#folding#fold_div_classes = 1
let g:pandoc#syntax#conceal#urls = 1
let g:pandoc#syntax#conceal#use = 1
let g:pandoc#syntax#codeblocks#embeds#use = 1
let g:pandoc#syntax#codeblocks#embeds#langs = ['vhdl', 'python', 'verilog', 'bash', 'tcl', 'cpp', 'vim', 'lua', 'vhams']

