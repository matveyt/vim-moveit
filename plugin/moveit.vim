" Vim plugin for moving blocks of text
" Maintainer:   matveyt
" Last Change:  2020 Feb 12
" License:      VIM License
" URL:          https://github.com/matveyt/vim-moveit

if exists('g:loaded_moveit')
    finish
endif
let g:loaded_moveit = 1

if !exists('g:no_plugin_maps') && !exists('g:no_moveit_maps')
    " keypad to move visual selection
    vnoremap <silent><unique><k4> :call moveit#to(v:count1..'h')<CR>
    vnoremap <silent><unique><k2> :call moveit#to(v:count1..'j')<CR>
    vnoremap <silent><unique><k8> :call moveit#to(v:count1..'k')<CR>
    vnoremap <silent><unique><k6> :call moveit#to(v:count1..'l')<CR>
endif
