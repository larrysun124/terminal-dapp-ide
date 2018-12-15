<<<<<<< HEAD
" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim
=======
if !exists("g:go_textobj_enabled")
  let g:go_textobj_enabled = 1
endif

if !exists("g:go_textobj_include_function_doc")
  let g:go_textobj_include_function_doc = 1
endif
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d

" ( ) motions
" { } motions
" s for sentence
<<<<<<< HEAD
" p for paragraph
" < >
" t for tag

function! go#textobj#Comment(mode) abort
  let l:fname = expand('%:p')

  try
    if &modified
      let l:tmpname = tempname()
      call writefile(go#util#GetLines(), l:tmpname)
      let l:fname = l:tmpname
    endif

    let l:cmd = ['motion',
          \ '-format', 'json',
          \ '-file', l:fname,
          \ '-offset', go#util#OffsetCursor(),
          \ '-mode', 'comment',
          \ ]

    let [l:out, l:err] = go#util#Exec(l:cmd)
    if l:err
      call go#util#EchoError(l:out)
      return
    endif
  finally
    if exists("l:tmpname")
      call delete(l:tmpname)
    endif
  endtry

  let l:result = json_decode(l:out)
  if type(l:result) != 4 || !has_key(l:result, 'comment')
    return
  endif

  let l:info = l:result.comment
  call cursor(l:info.startLine, l:info.startCol)

  " Adjust cursor to exclude start comment markers. Try to be a little bit
  " clever when using multi-line '/*' markers.
  if a:mode is# 'i'
    " trim whitespace so matching below works correctly
    let l:line = substitute(getline('.'), '^\s*\(.\{-}\)\s*$', '\1', '')

    " //text
    if l:line[:2] is# '// '
      call cursor(l:info.startLine, l:info.startCol+3)
    " // text
    elseif l:line[:1] is# '//'
      call cursor(l:info.startLine, l:info.startCol+2)
    " /*
    " text
    elseif l:line =~# '^/\* *$'
      call cursor(l:info.startLine+1, 0)
      " /*
      "  * text
      if getline('.')[:2] is# ' * '
        call cursor(l:info.startLine+1, 4)
      " /*
      "  *text
      elseif getline('.')[:1] is# ' *'
        call cursor(l:info.startLine+1, 3)
      endif
    " /* text
    elseif l:line[:2] is# '/* '
      call cursor(l:info.startLine, l:info.startCol+3)
    " /*text
    elseif l:line[:1] is# '/*'
      call cursor(l:info.startLine, l:info.startCol+2)
    endif
  endif

  normal! v

  " Exclude trailing newline.
  if a:mode is# 'i'
    let l:info.endCol -= 1
  endif

  call cursor(l:info.endLine, l:info.endCol)

  " Exclude trailing '*/'.
  if a:mode is# 'i'
    let l:line = getline('.')
    " text
    " */
    if l:line =~# '^ *\*/$'
      call cursor(l:info.endLine - 1, len(getline(l:info.endLine - 1)))
    " text */
    elseif l:line[-3:] is# ' */'
      call cursor(l:info.endLine, l:info.endCol - 3)
    " text*/
    elseif l:line[-2:] is# '*/'
      call cursor(l:info.endLine, l:info.endCol - 2)
    endif
  endif
endfunction

" Select a function in visual mode.
function! go#textobj#Function(mode) abort
  let l:fname = expand("%:p")
  if &modified
    let l:tmpname = tempname()
    call writefile(go#util#GetLines(), l:tmpname)
    let l:fname = l:tmpname
  endif

  let l:cmd = ['motion',
        \ '-format', 'vim',
        \ '-file', l:fname,
        \ '-offset', go#util#OffsetCursor(),
        \ '-mode', 'enclosing',
        \ ]

  if go#config#TextobjIncludeFunctionDoc()
    let l:cmd += ['-parse-comments']
  endif

  let [l:out, l:err] = go#util#Exec(l:cmd)
  if l:err
=======
" p for parapgrah
" < >
" t for tag

function! go#textobj#Function(mode)
  let offset = go#util#OffsetCursor()

  let fname = expand("%:p")
  if &modified
    " Write current unsaved buffer to a temp file and use the modified content
    let l:tmpname = tempname()
    call writefile(getline(1, '$'), l:tmpname)
    let fname = l:tmpname
  endif

  let bin_path = go#path#CheckBinPath('motion')
  if empty(bin_path)
    return
  endif

  let command = printf("%s -format vim -file %s -offset %s", bin_path, fname, offset)
  let command .= " -mode enclosing"

  if g:go_textobj_include_function_doc
    let command .= " -parse-comments"
  endif

  let out = system(command)
  if v:shell_error != 0
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
    call go#util#EchoError(out)
    return
  endif

  " if exists, delete it as we don't need it anymore
  if exists("l:tmpname")
    call delete(l:tmpname)
  endif

  " convert our string dict representation into native Vim dictionary type
  let result = eval(out)
  if type(result) != 4 || !has_key(result, 'fn')
    return
  endif

  let info = result.fn

  if a:mode == 'a'
    " anonymous functions doesn't have associated doc. Also check if the user
    " want's to include doc comments for function declarations
<<<<<<< HEAD
    if has_key(info, 'doc') && go#config#TextobjIncludeFunctionDoc()
      call cursor(info.doc.line, info.doc.col)
    elseif info['sig']['name'] == '' && go#config#TextobjIncludeVariable()
      " one liner anonymous functions
      if info.lbrace.line == info.rbrace.line
        " jump to first nonblack char, to get the correct column
        call cursor(info.lbrace.line, 0 )
        normal! ^
        call cursor(info.func.line, col("."))
      else
        call cursor(info.func.line, info.rbrace.col)
      endif
=======
    if has_key(info, 'doc') && g:go_textobj_include_function_doc
      call cursor(info.doc.line, info.doc.col)
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
    else
      call cursor(info.func.line, info.func.col)
    endif

    normal! v
    call cursor(info.rbrace.line, info.rbrace.col)
    return
<<<<<<< HEAD
  endif
=======
  endif 
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d

  " rest is inner mode, a:mode == 'i'

  " if the function is a one liner we need to select only that portion
  if info.lbrace.line == info.rbrace.line
    call cursor(info.lbrace.line, info.lbrace.col+1)
    normal! v
    call cursor(info.rbrace.line, info.rbrace.col-1)
    return
  endif

  call cursor(info.lbrace.line+1, 1)
  normal! V
  call cursor(info.rbrace.line-1, 1)
endfunction

<<<<<<< HEAD
" Get the location of the previous or next function.
function! go#textobj#FunctionLocation(direction, cnt) abort
  let l:fname = expand("%:p")
  if &modified
    " Write current unsaved buffer to a temp file and use the modified content
    let l:tmpname = tempname()
    call writefile(go#util#GetLines(), l:tmpname)
    let l:fname = l:tmpname
  endif

  let l:cmd = ['motion',
        \ '-format', 'vim',
        \ '-file', l:fname,
        \ '-offset', go#util#OffsetCursor(),
        \ '-shift', a:cnt,
        \ '-mode', a:direction,
        \ ]

  if go#config#TextobjIncludeFunctionDoc()
    let l:cmd += ['-parse-comments']
  endif

  let [l:out, l:err] = go#util#Exec(l:cmd)
  if l:err
=======
function! go#textobj#FunctionJump(mode, direction)
  " get count of the motion. This should be done before all the normal
  " expressions below as those reset this value(because they have zero
  " count!). We abstract -1 because the index starts from 0 in motion.
  let l:cnt = v:count1 - 1

  " set context mark so we can jump back with  '' or ``
  normal! m'

  " select already previously selected visual content and continue from there.
  " If it's the first time starts with the visual mode. This is needed so
  " after selecting something in visual mode, every consecutive motion
  " continues.
  if a:mode == 'v'
    normal! gv
  endif

  let offset = go#util#OffsetCursor()

  let fname = expand("%:p")
  if &modified
    " Write current unsaved buffer to a temp file and use the modified content
    let l:tmpname = tempname()
    call writefile(getline(1, '$'), l:tmpname)
    let fname = l:tmpname
  endif

  let bin_path = go#path#CheckBinPath('motion')
  if empty(bin_path)
    return
  endif

  let command = printf("%s -format vim -file %s -offset %s", bin_path, fname, offset)
  let command .= ' -shift ' . l:cnt

  if a:direction == 'next'
    let command .= ' -mode next'
  else " 'prev'
    let command .= ' -mode prev'
  endif

  if g:go_textobj_include_function_doc
    let command .= " -parse-comments"
  endif

  let out = system(command)
  if v:shell_error != 0
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
    call go#util#EchoError(out)
    return
  endif

  " if exists, delete it as we don't need it anymore
  if exists("l:tmpname")
    call delete(l:tmpname)
  endif

<<<<<<< HEAD
  let l:result = json_decode(out)
  if type(l:result) != 4 || !has_key(l:result, 'fn')
    return 0
  endif

  return l:result
endfunction

function! go#textobj#FunctionJump(mode, direction) abort
  " get count of the motion. This should be done before all the normal
  " expressions below as those reset this value(because they have zero
  " count!). We abstract -1 because the index starts from 0 in motion.
  let l:cnt = v:count1 - 1

  " set context mark so we can jump back with  '' or ``
  normal! m'

  " select already previously selected visual content and continue from there.
  " If it's the first time starts with the visual mode. This is needed so
  " after selecting something in visual mode, every consecutive motion
  " continues.
  if a:mode == 'v'
    normal! gv
  endif

  let l:result = go#textobj#FunctionLocation(a:direction, l:cnt)
  if l:result is 0
=======
  " convert our string dict representation into native Vim dictionary type
  let result = eval(out)
  if type(result) != 4 || !has_key(result, 'fn')
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
    return
  endif

  " we reached the end and there are no functions. The usual [[ or ]] jumps to
  " the top or bottom, we'll do the same.
  if type(result) == 4 && has_key(result, 'err') && result.err == "no functions found"
    if a:direction == 'next'
      keepjumps normal! G
    else " 'prev'
      keepjumps normal! gg
    endif
    return
  endif

  let info = result.fn

  " if we select something ,select all function
  if a:mode == 'v' && a:direction == 'next'
    keepjumps call cursor(info.rbrace.line, 1)
    return
  endif

  if a:mode == 'v' && a:direction == 'prev'
<<<<<<< HEAD
    if has_key(info, 'doc') && go#config#TextobjIncludeFunctionDoc()
=======
    if has_key(info, 'doc') && g:go_textobj_include_function_doc
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
      keepjumps call cursor(info.doc.line, 1)
    else
      keepjumps call cursor(info.func.line, 1)
    endif
    return
  endif

  keepjumps call cursor(info.func.line, 1)
endfunction

<<<<<<< HEAD
" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======
" vim:ts=2:sw=2:et
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
