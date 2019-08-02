" Vim plugin for moving blocks of text
" Maintainer:   matveyt
" Last Change:  2019 Jul 31
" License:      VIM License
" URL:          https://github.com/matveyt/vim-moveit

" to improve line wrapping support
let s:cmd = #{h: "\<BS>", j: "gj", k: "gk", l: "\<Space>"}

function! moveit#to(motion) range
    " parse input argument
    let l:mode = visualmode()
    let l:count = max([str2nr(a:motion), 1])
    let l:dir = a:motion[-1:]
    if empty(l:mode) || stridx('hjkl', l:dir) < 0
        return
    endif

    " try to join consecutive moves into a single undo
    if get(b:, 'moveit_undo', -1) == undotree().seq_cur
        silent! undojoin
    endif

    " now move it
    if l:mode ==# 'V'
        " use Ex in linewise mode
        call execute(printf("'<,'>move '%s%d", (l:dir ==# 'h' || l:dir ==# 'k') ?
            \ '<--' : '>+', l:count), 'silent!')
    else
        " delete & move cursor & put
        call execute(printf("normal! gvd%d%sP", l:count, s:cmd[l:dir]), 'silent!')
    endif
    " restore selection
    call execute(printf("normal! `[%s`]%so", l:mode, &sel ==# 'exclusive' ? 'l' : ''))

    " remember current undo number
    let b:moveit_undo = undotree().seq_cur
endfunction
