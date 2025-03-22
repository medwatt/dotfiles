function! CopyLines(reg)
    let save_cursor = getpos(".")
    let lines = []
    g//let lines += [getline('.')]
    let reg = empty(a:reg) ? '+' : a:reg
    execute 'let @'.reg.' = join(lines, "\n") . "\n"'
    call setpos('.', save_cursor)
endfunction

function! CopyMatches(reg)
    let hits = []
    %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
    let reg = empty(a:reg) ? '+' : a:reg
    execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction

command! -register CopyLines call CopyLines(<q-reg>)
command! -register CopyMatches call CopyMatches(<q-reg>)
