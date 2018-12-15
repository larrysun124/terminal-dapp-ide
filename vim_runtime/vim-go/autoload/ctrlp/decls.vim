<<<<<<< HEAD
" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

let s:go_decls_var = {
      \  'init':   'ctrlp#decls#init()',
      \  'exit':   'ctrlp#decls#exit()',
      \  'enter':  'ctrlp#decls#enter()',
      \  'accept': 'ctrlp#decls#accept',
      \  'lname':  'declarations',
      \  'sname':  'decls',
      \  'type':   'tabs',
      \}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:go_decls_var)
else
  let g:ctrlp_ext_vars = [s:go_decls_var]
endif

function! ctrlp#decls#init() abort
  cal s:enable_syntax()
  return s:decls
endfunction

function! ctrlp#decls#exit() abort
  unlet! s:decls s:target
=======
let s:go_decls_var = {
			\  'init':   'ctrlp#decls#init()',
			\  'exit':   'ctrlp#decls#exit()',
			\  'enter':  'ctrlp#decls#enter()',
			\  'accept': 'ctrlp#decls#accept',
			\  'lname':  'declarations',
			\  'sname':  'decls',
			\  'type':   'tabs',
			\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
	let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:go_decls_var)
else
	let g:ctrlp_ext_vars = [s:go_decls_var]
endif

function! ctrlp#decls#init()
	cal s:enable_syntax()
	return s:decls
endfunction

function! ctrlp#decls#exit()
	unlet! s:decls s:current_dir s:target
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
endfunction

" The action to perform on the selected string
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
<<<<<<< HEAD
function! ctrlp#decls#accept(mode, str) abort
  let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
  let dir = getcwd()
  try
    let vals = matchlist(a:str, '|\(.\{-}\):\(\d\+\):\(\d\+\)\s*\(.*\)|')

    " i.e: main.go
    let filename =  vals[1]
    let line =  vals[2]
    let col =  vals[3]

    " i.e: /Users/fatih/vim-go/main.go
    let filepath =  fnamemodify(filename, ":p")

    " acceptile is a very versatile method,
    call ctrlp#acceptfile(a:mode, filepath)
    call cursor(line, col)
    silent! norm! zvzz
  endtry
endfunction

function! ctrlp#decls#enter() abort
  let s:decls = []

  let l:cmd = ['motion',
        \ '-format', 'vim',
        \ '-mode', 'decls',
        \ '-include', go#config#DeclsIncludes(),
        \ ]

  call go#cmd#autowrite()

  if s:mode == 0
    " current file mode
    let l:fname = expand("%:p")
    if exists('s:target')
      let l:fname = s:target
    endif

    let cmd += ['-file', l:fname]
  else
    " all functions mode
    let l:dir = expand("%:p:h")
    if exists('s:target')
      let l:dir = s:target
    endif

    let cmd += ['-dir', l:dir]
  endif

  let [l:out, l:err] = go#util#Exec(l:cmd)
  if l:err
    call go#util#EchoError(l:out)
    return
  endif

  let result = eval(out)
  if type(result) != 4 || !has_key(result, 'decls')
    return
  endif

  let decls = result.decls

  " find the maximum function name
  let max_len = 0
  for decl in decls
    if len(decl.ident)> max_len
      let max_len = len(decl.ident)
    endif
  endfor

  for decl in decls
    " paddings
    let space = " "
    for i in range(max_len - len(decl.ident))
      let space .= " "
    endfor

    call add(s:decls, printf("%s\t%s |%s:%s:%s|\t%s",
          \ decl.ident . space,
          \ decl.keyword,
          \ fnamemodify(decl.filename, ":p"),
          \ decl.line,
          \ decl.col,
          \ decl.full,
          \))
  endfor
endfunc

function! s:enable_syntax() abort
  if !(has('syntax') && exists('g:syntax_on'))
    return
  endif

  syntax match CtrlPIdent      '\zs\h\+\ze\s'
  syntax match CtrlPKeyword		 '\zs[^\t|]\+\ze|[^|]\+:\d\+:\d\+|'
  syntax match CtrlPFilename   '|\zs[^|]\+:\d\+:\d\+\ze|'
  syntax match CtrlPSignature  '\zs\t.*\ze$' contains=CtrlPKeyWord,CtrlPFilename

  highlight link  CtrlPIdent      Function
  highlight link  CtrlPKeyword   Keyword
  highlight link  CtrlPFilename  SpecialComment
  highlight link  CtrlPSignature Comment
=======
function! ctrlp#decls#accept(mode, str)
	let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
	let dir = getcwd()
	try
		" we jump to the file directory so we can get the fullpath via fnamemodify
		" below
		execute cd . s:current_dir

		let vals = matchlist(a:str, '|\(.\{-}\):\(\d\+\):\(\d\+\)\s*\(.*\)|')

		" i.e: main.go
		let filename =  vals[1] 
		let line =  vals[2]
		let col =  vals[3]

		" i.e: /Users/fatih/vim-go/main.go
		let filepath =  fnamemodify(filename, ":p")

		" acceptile is a very versatile method,
		call ctrlp#acceptfile(a:mode, filepath)
		call cursor(line, col)
		silent! norm! zvzz
	finally
		"jump back to old dir
		execute cd . fnameescape(dir)
	endtry
endfunction

function! ctrlp#decls#enter()
	let s:current_dir = fnameescape(expand('%:p:h'))
	let s:decls = []

	let bin_path = go#path#CheckBinPath('motion')
	if empty(bin_path)
		return
	endif
	let command = printf("%s -format vim -mode decls", bin_path)
	let command .= " -include ".  get(g:, "go_decls_includes", "func,type")

	call go#cmd#autowrite()

	if s:mode == 0
		" current file mode
		let fname = expand("%:p")
		if exists('s:target')
			let fname = s:target
		endif

		let command .= printf(" -file %s", fname)
	else
		" all functions mode
		let dir = expand("%:p:h")
		if exists('s:target')
			let dir = s:target
		endif

		let command .= printf(" -dir %s", dir)
	endif

	let out = system(command)
	if v:shell_error != 0
		call go#util#EchoError(out)
		return
	endif

	if exists("l:tmpname")
		call delete(l:tmpname)
	endif

	let result = eval(out)
	if type(result) != 4 || !has_key(result, 'decls')
		return
	endif

	let decls = result.decls

	" find the maximum function name
	let max_len = 0
	for decl in decls
		if len(decl.ident)> max_len
			let max_len = len(decl.ident)
		endif
	endfor

	for decl in decls
		" paddings
		let space = " "
		for i in range(max_len - len(decl.ident))
			let space .= " "
		endfor

		call add(s:decls, printf("%s\t%s |%s:%s:%s|\t%s", 
					\ decl.ident . space,
					\ decl.keyword,
					\ fnamemodify(decl.filename, ":t"),
					\ decl.line,
					\ decl.col,
					\ decl.full,
					\))
	endfor
endfunc

function! s:enable_syntax()
	if !(has('syntax') && exists('g:syntax_on'))
		return
	endif

	syntax match CtrlPIdent      '\zs\h\+\ze\s' 
	syntax match CtrlPKeyword		 '\zs[^\t|]\+\ze|[^|]\+:\d\+:\d\+|'
	syntax match CtrlPFilename   '|\zs[^|]\+:\d\+:\d\+\ze|'
	syntax match CtrlPSignature  '\zs\t.*\ze$' contains=CtrlPKeyWord,CtrlPFilename

	highlight link  CtrlPIdent      Function
	highlight link  CtrlPKeyword   Keyword
	highlight link  CtrlPFilename  SpecialComment
	highlight link  CtrlPSignature Comment
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

<<<<<<< HEAD
function! ctrlp#decls#cmd(mode, ...) abort
  let s:mode = a:mode
  if a:0 && !empty(a:1)
    let s:target = a:1
  endif
  return s:id
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======
function! ctrlp#decls#cmd(mode, ...)
	let s:mode = a:mode
	if a:0 && !empty(a:1)
		let s:target = a:1
	endif
	return s:id
endfunction

>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
