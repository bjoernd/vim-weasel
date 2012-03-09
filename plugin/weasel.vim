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

" DEBUG: This function unloads the script so that we can reload
"        it with new mappings and functions.
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
" A test for the the functionality of finding
" duplicate words. To figure this this out, we
" have this text here with a lot of words and one
" one might easily miss a duplicate in here, so the
" script is hopefully going to help us find find these 
" errors.


" Returns true if a string is a word.
function! s:Skip_nonword(word)
    if a:word !~ '[a-zA-Z]\+'
        return 1
    else
        return 0
    endif
endfunction

" Write list of results into error file.
function! s:WriteErrors(resList)
	"XXX make file configurable
	call writefile(a:resList, "/tmp/weasel_errors.txt")
endfunction

" Open error file in quickfix window
function! s:OpenQuickfix()
	"XXX make file configurable
	execute "cfile /tmp/weasel_errors.txt"
	execute "copen 10"
endfunction

" Find repeated words (within a line as well as across
" adjacent lines).
function! s:RepeatWords(line,number)

	let res = []

	for w in split(a:line)

		if s:Skip_nonword(w)
			continue
		endif
		" XXX: Might want to skip "syntax" elements,
		"      e.g., of a programming language as well

		if w == s:lastword
			let res += [bufname("%").":".a:number.":'".s:lastword."' repeated"] 
		endif

		" don't forget to store last word
		let s:lastword = w

	endfor

	return res
endfunction


" Main function. Iterates over all lines in the current buffer.
function! s:WeaselFunc()
	let s:lastword = ""

	let lines    = getline(0, "$") " read all lines
	let lineno   = 0               " current line #
	let resList  = []              " list of errors

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
