" Vim plugin for moving blocks of text
" Maintainer:   matveyt
" Last Change:  2019 Sep 16
" License:      VIM License
" URL:          https://github.com/matveyt/vim-moveit

" allow line wrap
let s:cmd = {'h': "\<BS>", 'j': "gj", 'k': "gk", 'l': "\<Space>"}

function! s:execf(fmt, ...)
    return execute(repeat('undojoin|', get(b:, 'moveit_undo', -1) == undotree().seq_cur)
        \ . call('printf', extend([a:fmt], a:000)), 'silent!')
endfunction

function! moveit#to(motion) range
    " parse input argument
    let l:mode = visualmode()
    let l:count = max([str2nr(a:motion), 1])
    let l:dir = a:motion[-1:]
    let l:back = (l:dir ==# 'h' || l:dir ==# 'k')
    if !&modifiable || empty(l:mode) || stridx('hjkl', l:dir) < 0
        return
    endif

    if l:mode ==# 'V'
        " 'V' is different as we :move
        let l:count = min([l:count, l:back ? a:firstline - 1 : line('$') - a:lastline])
        if l:count < 1
            normal! gv
            return
        endif
        call s:execf("*move '%s%d", l:back ? '<--' : '>+', l:count)
    else
        " delete & move cursor & set marks & put
        " note: 'y' is used to spare 1-9 regs
        call s:execf(join(['normal! gvygv"_c', '%d%s', 'm<', 'gP', '%s', "m>\<C-C>"],
            \ "\<C-\>\<C-O>"), l:count, s:cmd[l:dir],
            \ &selection ==# 'inclusive' ? s:cmd['h'] : "\<Esc>")

        " adjust '< if there was a virtual offset (e.g. EOL) before 'put'
        let l:begin = getpos("'<")
        if l:begin[3]
            let l:begin[2] += l:begin[3]
            let l:begin[3] = 0
            call setpos("'<", l:begin)
        endif

        " trim excessive space
        if get(g:, 'moveit_trim', 1)
            let l:begin = max([a:firstline, and(-l:back, line("'>")) + 1])
            let l:end = min([a:lastline, and(-l:back, a:lastline) + line("'<") - 1])
            if l:begin <= l:end
                call s:execf('%d,%ds/\s\+$//', l:begin, l:end)
            endif
        endif
    endif

    " restore selection (note: 'gv' fails on $-blocks)
    call s:execf('normal! g`<%sg`>%s', l:mode, l:back ? 'o' : '')
    " remember current undo number
    let b:moveit_undo = undotree().seq_cur
endfunction
