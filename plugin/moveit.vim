" Vim plugin for moving blocks of text
" Maintainer:   matveyt
" Last Change:  2022 Aug 11
" License:      VIM License
" URL:          https://github.com/matveyt/vim-moveit

if exists('g:loaded_moveit')
    finish
endif
let g:loaded_moveit = 1

if !hasmapto('moveit#to', 'v')
    " keypad to move visual selection
    xnoremap <silent><unique><k4> :call moveit#to(v:count1..'h')<CR>
    xnoremap <silent><unique><k2> :call moveit#to(v:count1..'j')<CR>
    xnoremap <silent><unique><k8> :call moveit#to(v:count1..'k')<CR>
    xnoremap <silent><unique><k6> :call moveit#to(v:count1..'l')<CR>
endif
