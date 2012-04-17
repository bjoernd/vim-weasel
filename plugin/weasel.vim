" Vim plugin for handling Matt Might's recommendations on writing
" style. For details see
" http://matt.might.net/articles/shell-scripts-for-passive-voice-weasel-words-duplicates/
" Last Change:  2012-04-17
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


" =================================================
" Helper functions
" =================================================

" Returns true if a string is a word.
function! s:IsWord(word)
    if a:word =~ '[a-zA-Z]\+'
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


" Find out of a list contains an item.
"
" XXX: I'm pretty sure that VIML already has such a function
"      and I just didn't find it. :(
function! s:Contains(liste, item)
	for l in a:liste
		if l == a:item
			return 1
		endif
	endfor
	return 0
endfunction



" === TEST WEASEL WORDS ===
"
" This text has significantly more content than I would
" have expected. This is extremely nice and remarkably great.
" Surprisingly, I like this text substantially more than others.
"
"  Bad:    It is quite difficult to find untainted samples.
"  Better: It is difficult to find untainted samples.
"
"  Bad:    We used various methods to isolate four samples.
"  Better: We isolated four samples.
"
"  Bad:    False positives were surprisingly low.
"  Better: To our surprise, false positives were low.
"  Good:   To our surprise, false positives were low (3%).
"
"  Bad:    There is very close match between the two semantics.
"  Better: There is a close match between the two semantics.
"
"  Bad:    We offer a completely different formulation of CFA.
"  Better: We offer a different formulation of CFA.
function! s:WeaselWords(word)
	let weasels=["many","various","very","fairly","several", 
				 \ "extremely","exceedingly","quite","remarkably",
				 \ "few","surprisingly", "mostly","largely","huge",
				 \ "tiny","a number", "excellent","interestingly",
				 \ "significantly", "substantially","clearly",
				 \ "vast","relatively","completely"]
	let res = []

	let w2 = tolower(a:word)
	let w2 = substitute(w2, "[,.:?!]", "", "g")
	if s:Contains(weasels, w2)
		return 1
	endif

	return 0
endfunction



" === TEST PASSIVE ===
"
"  have been implemented
"  i am bound to say
"
"  Bad:    Termination is guaranteed on any input.
"  Better: Termination is guaranteed on any input by a finite state-space.
"  OK:     A finite state-space guarantees termination on any input.

" Find passive voice
function! s:PassiveWords(word)
	let irregulars= ["awoken","been","born","beat","become","begun","bent",
				\ "beset","bet","bid","bidden","bound","bitten",
				\ "bled","blown","broken","bred","brought","broadcast",
				\ "built","burnt","burst","bought","cast","caught",
				\ "chosen","clung","come","cost","crept","cut",
				\ "dealt","dug","dived","done","drawn","dreamt",
				\ "driven","drunk","eaten","fallen","fed","felt","fought","found",
				\ "fit","fled","flung","flown","forbidden","forgotten",
				\ "foregone","forgiven","forsaken","frozen",
				\ "gotten","given","gone","ground","grown","hung",
				\ "heard","hidden","hit","held","hurt","kept","knelt",
				\ "knit","known","laid","led","leapt","learnt","left",
				\ "lent","let","lain","lighted","lost","made","meant","met",
				\ "misspelt","mistaken","mown","overcome","overdone","overtaken",
				\ "overthrown","paid","pled","proven","put","quit","read","rid","ridden",
				\ "rung","risen","run","sawn","said","seen","sought","sold","sent",
				\ "set","sewn","shaken","shaven","shorn","shed","shone","shod",
				\ "shot","shown","shrunk","shut","sung","sunk","sat","slept",
				\ "slain","slid","slung","slit","smitten","sown","spoken","sped",
				\ "spent","spilt","spun","spit","split","spread","sprung","stood",
				\ "stolen","stuck","stung","stunk","stridden","struck","strung",
				\ "striven","sworn","swept","swollen","swum","swung","taken",
				\ "taught","torn","told","thought","thrived","thrown","thrust",
				\ "trodden","understood","upheld","upset","woken","worn","woven",
				\ "wed","wept","wound","won","withheld","withstood","wrung","written"]

	let passive_words = ["am","are","were","being","is","been","was","be"]

	let last = tolower(s:lastword)
	if s:Contains(passive_words, last)
		let w2 = tolower(a:word)
		let w2 = substitute(w2, "[,.:?!]", "", "g")
		if s:Contains(irregulars, w2)
			return 1
		endif
		if w2 =~? '\w\+ed'
			return 1
		endif
	endif

	return 0
endfunction



" === TEST REPEATED WORDS ===
" A test for the the functionality of finding
" duplicate words. To figure this this out, we
" have this text here with a lot of words and one
" one might easily miss a duplicate in here, so the
" script is hopefully going to help us find find these 
" errors.
"
"  Many readers are not aware that the
"  the brain will automatically ignore
"  a second instance of the word "the"
"  when it starts a new line. 
" 
"  Many readers are not aware that the the
"  brain will automatically ignore a second
"  instance of the word "the" when it starts
"  a new line. 

" Find repeated words (within a line as well as across
" adjacent lines).
function! s:RepeatWords(word)
	if a:word == s:lastword
		return 1
	endif
	return 0
endfunction


" Word loop. Iterates over the words in a line and calls the
" error checkers. If an error is found, adds a resulting line
" to the future quickfix buffer.
"
" Also, this function keeps track of the s:lastword variable
" containing the previous word as it is used by multiple
" checkers.
function! s:WordLoop(line, number)
	let res = []

	for w in split(a:line)
		if !s:IsWord(w)
			continue
		endif

		" XXX: make the actual checkers used configurable

		if s:RepeatWords(w)
			let res += [bufname("%").":".a:number.":'".s:lastword."' repeated"] 
		endif

		if s:WeaselWords(w)
			let res += [bufname("%").":".a:number.": Weasel word: '".w."'"]
		endif

		if s:PassiveWords(w)
			let res += [bufname("%").":".a:number.": Passive voice: '".s:lastword." ".w."'"] 
		endif

		let s:lastword = w
	endfor

	return res
endfunction


" Main function. Iterates over all lines in the current buffer and
" afterwards opens the quickfix window.
function! s:WeaselFunc()
	let s:lastword = ""

	let lines    = getline(0, "$") " read all lines
	let lineno   = 0               " current line #
	let resList  = []              " list of errors

	for l in lines
	   let lineno  += 1
	   let resList += s:WordLoop(l, lineno)
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
