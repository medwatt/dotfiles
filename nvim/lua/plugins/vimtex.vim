"----------General Tex----------"
set conceallevel=0
let g:tex_flavor='latex'
" let g:tex_stylish = 1
" let g:tex_conceal = ''
" let g:tex_conceal='abdmg'
" hi Conceal ctermbg=noneg

let g:vimtex_imaps_enabled = 0 " disable insert mode mappings
imap <plug>(disable-]]) <plug>(vimtex-delim-close)

"----------VimTex----------"
let g:vimtex_syntax_enabled = 0
let g:vimtex_quickfix_mode = 0 " The quickfix window is never opened/closed automatically
let g:vimtex_view_method = 'zathura'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_compiler_latexmk = {
        \ 'build_dir' : 'out',
        \ 'callback' : 1,
        \ 'continuous' : 0,
        \ 'executable' : 'latexmk',
        \ 'hooks' : [],
        \ 'options' : [
        \  '-xelatex',
        \   '-verbose',
        \   '-shell-escape',
        \   '-file-line-error',
        \   '-synctex=1',
        \   '-interaction=nonstopmode',
        \ ],
        \}

" let g:vimtex#re#neocomplete =
"       \ '\v\\%('
"       \ .  '%(\a*cite|Cite)\a*\*?%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
"       \ . '|%(\a*cites|Cites)%(\s*\([^)]*\)){0,2}'
"       \     . '%(%(\s*\[[^]]*\]){0,2}\s*\{[^}]*\})*'
"       \     . '%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
"       \ . '|bibentry\s*\{[^}]*'
"       \ . '|%(text|block)cquote\*?%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
"       \ . '|%(for|hy)\w*cquote\*?\{[^}]*}%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
"       \ . '|defbibentryset\{[^}]*}\{[^}]*'
"       \ . '|\a*ref%(\s*\{[^}]*|range\s*\{[^,}]*%(}\{)?)'
"       \ . '|hyperref\s*\[[^]]*'
"       \ . '|includegraphics\*?%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
"       \ . '|%(include%(only)?|input|subfile)\s*\{[^}]*'
"       \ . '|([cpdr]?(gls|Gls|GLS)|acr|Acr|ACR)\a*\s*\{[^}]*'
"       \ . '|(ac|Ac|AC)\s*\{[^}]*'
"       \ . '|includepdf%(\s*\[[^]]*\])?\s*\{[^}]*'
"       \ . '|includestandalone%(\s*\[[^]]*\])?\s*\{[^}]*'
"       \ . '|%(usepackage|RequirePackage|PassOptionsToPackage)%(\s*\[[^]]*\])?\s*\{[^}]*'
"       \ . '|documentclass%(\s*\[[^]]*\])?\s*\{[^}]*'
"       \ . '|begin%(\s*\[[^]]*\])?\s*\{[^}]*'
"       \ . '|end%(\s*\[[^]]*\])?\s*\{[^}]*'
"       \ . '|\a*'
"       \ . ')'
