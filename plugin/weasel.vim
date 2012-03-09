" Vim plugin for handling Matt Might's recommendations on writing
" style. For details see <XXX INSERT URL>
" Last Change:
" Maintainer: 	Björn Döbel <doebel@tudos.org>
" License: 		This file is placed in the public domain

if exists("g:loaded_weasel")
	echo "Already loaded"
	finish
endif
let g:loaded_weasel = 1


function! s:UnloadWeasel()
	unlet g:loaded_weasel
endfunction

if !hasmapto('<Plug>UnloadWeasel')
	map <unique> <Leader>u <Plug>WeaselUnload
	noremap <unique> <script> <Plug>WeaselUnload <SID>UnloadWeasel
	noremap <SID>UnloadWeasel :call <SID>UnloadWeasel()<CR>
endif
