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

	unmap <Leader>w
	unmap <Plug>WeaselFunc
	unmap <SID>WeaselFunc
endfunction

" 
" A test the the


function! s:Skip_nonword(word)
    if a:word !~ '[a-zA-Z]\+'
        return 1
    else
        return 0
    endif
endfunction

function! s:WriteErrors(resList)
	call writefile(a:resList, "/tmp/weasel_errors.txt")
endfunction

function! s:OpenQuickfix()
	"XXX make file configurable
	execute "cfile /tmp/weasel_errors.txt"
	execute "copen 10"
endfunction

function! s:RepeatWords(line,number)
	let res = []
	for w in split(a:line)
		if s:Skip_nonword(w)
			continue
		endif
		if w == s:lastword
			let res += [bufname("%").":".a:number.":".s:lastword." repeated"] 
		endif
		let s:lastword = w
	endfor
	return res
endfunction


function! s:WeaselFunc()
	let s:lastword = ""

	let lines    = getline(0, "$") "read all lines
	let lineno   = 0               "current line #
	let resList  = []              "list of errors

	for l in lines
	   let lineno  += 1
	   let resList += s:RepeatWords(l, lineno)
	endfor

	call s:WriteErrors(resList)
	call s:OpenQuickfix()
endfunction


if !hasmapto('<Plug>UnloadWeasel')
	map <unique> <Leader>u <Plug>WeaselUnload
	noremap <unique> <script> <Plug>WeaselUnload <SID>UnloadWeasel
	noremap <SID>UnloadWeasel :call <SID>UnloadWeasel()<CR>
endif


if !hasmapto('<Plug>WeaselFunc')
	map <unique> <Leader>w <Plug>WeaselFunc
	noremap <unique> <script> <Plug>WeaselFunc <SID>WeaselFunc
	noremap <SID>WeaselFunc :call <SID>WeaselFunc()<CR>
endif
