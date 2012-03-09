" Vim plugin for handling Matt Might's recommendations on writing
" style. For details see <XXX INSERT URL>
" Last Change:  2012-03-09
" Maintainer: 	Björn Döbel <doebel@tudos.org>
" License: 		This file is placed in the public domain

if exists("g:loaded_weasel")
	echo "Already loaded"
	finish
endif
let g:loaded_weasel = 1


function! s:UnloadWeasel()
	unlet g:loaded_weasel

	unmap <Leader>u
	unmap <Plug>WeaselUnload
	unmap <SID>UnloadWeasel

	unmap <Leader>r
	unmap <Plug>WeaselRepeated
	unmap <SID>RepeatedWords
endfunction

" 
" A test the the

function! s:RepeatedWords()
	call Dfunc("RepeatedWords")
	let lines = getline(0, "$")
	Decho("Lines: ".len(lines))
	let lastword = ""
	let lineno = 0
	let resList = []
	for l in lines
		let lineno += 1
		for w in split(l)
			" Skip non-words
			if w !~ '[a-zA-Z]\+'
				continue
			endif
			if w == lastword
				let resList += [lineno, lastword]
				Decho("Repeat: ".lastword)
			endif
			let lastword = w
		endfor
	endfor
	Decho("lastword: ".lastword)
	Decho(resList)
	call Dret("RepeatedWords")
endfunction


if !hasmapto('<Plug>UnloadWeasel')
	map <unique> <Leader>u <Plug>WeaselUnload
	noremap <unique> <script> <Plug>WeaselUnload <SID>UnloadWeasel
	noremap <SID>UnloadWeasel :call <SID>UnloadWeasel()<CR>
endif


if !hasmapto('<Plug>WeaselRepeated')
	map <unique> <Leader>r <Plug>WeaselRepeated
	noremap <unique> <script> <Plug>WeaselRepeated <SID>RepeatedWords
	noremap <SID>RepeatedWords :call <SID>RepeatedWords()<CR>
endif
