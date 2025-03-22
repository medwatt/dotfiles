function TrimWhiteSpace()
    let save_cursor = getcurpos()
    %s/\s\+$//e
    call setpos('.', save_cursor)
endfunction

autocmd BufWritePre * call TrimWhiteSpace()

" function VisualStarSearch(cmdtype,...)
"     let temp = @"
"     normal! gvy
"     if !a:0 || a:1 != 'raw'
"         let @" = escape(@", a:cmdtype.'\*')
"     endif
"     let @/ = substitute(@", '\n', '\\n', 'g')
"     let @/ = substitute(@/, '\[', '\\[', 'g')
"     let @/ = substitute(@/, '\~', '\\~', 'g')
"     let @/ = substitute(@/, '\.', '\\.', 'g')
"     let @" = temp
" endfunction

function VVV()
    let pat = '''\|"\|]\|)\|\}'
    let [l, c] = searchpos(pat)
    let m = getline(l)[c-1]
    execute "normal! ci" .. m
    normal! a
endfunction


" Get highlight group of text under cursor
function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()


