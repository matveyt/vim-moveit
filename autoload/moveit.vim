" Vim plugin for moving blocks of text
" Maintainer:   matveyt
" Last Change:  2019 Aug 8
" License:      VIM License
" URL:          https://github.com/matveyt/vim-moveit

" allow line wrap
let s:cmd = {'h': "\<BS>", 'j': "gj", 'k': "gk", 'l': "\<Space>"}

function! s:execf(fmt, ...)
    call execute(call('printf', [a:fmt] + a:000), 'silent!')
endfunction

function! moveit#to(motion) range
    " parse input argument
    let l:mode = visualmode()
    let l:count = max([str2nr(a:motion), 1])
    let l:dir = a:motion[-1:]
    let l:corner = (l:dir ==# 'h' || l:dir ==# 'k') ? 'o' : ''
    if empty(l:mode) || stridx('hjkl', l:dir) < 0
        return
    endif

    " join consecutive moves into a single undo
    if get(b:, 'moveit_undo', -1) == undotree().seq_cur
        silent! undojoin
    endif

    if l:mode ==# 'V'
        " 'V' is different as we use :move
        if empty(l:corner) "down
            let l:dir = ">+"
            let l:count = min([l:count, line("$") - line("'>")])
        else "up
            let l:dir = "<--"
            let l:count = min([l:count, line("'<") - 1])
        endif
        if l:count > 0
            call s:execf("'<,'>move '%s%d", l:dir, l:count)
        else
            normal! gv
            return
        endif
    else
        " both 'v' and <C-V>
        " use 'y' to spare 1-9 registers
        normal! gvy
        " must extend visual selection over the last char
        if &sel ==# 'exclusive'
            let l:corner = s:cmd['l'] . l:corner
        endif
        " if last char is \n then `] gets on the next line
        if @@[-1:] ==# "\n"
            let l:corner = s:cmd['h'] . l:corner
        endif
        " delete & move cursor & put
        call s:execf("normal! gv\"_c\<C-\>\<C-O>%d%s\<C-\>\<C-O>m'\<C-\>\<C-O>P\<C-C>",
            \ l:count, s:cmd[l:dir])
        " alas, but sometimes we have to adjust `[ too
        let l:pos = getpos("''")
        call setpos("'[", [0, l:pos[1], l:pos[2] + l:pos[3], 0])
    endif

    " restore selection
    call s:execf("normal! `[%s`]%s", l:mode, l:corner)
    " remember current undo number
    let b:moveit_undo = undotree().seq_cur
endfunction
