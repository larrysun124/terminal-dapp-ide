" Copyright 2011 The Go Authors. All rights reserved.
" Use of this source code is governed by a BSD-style
" license that can be found in the LICENSE file.
<<<<<<< HEAD

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

let s:buf_nr = -1

function! go#doc#OpenBrowser(...) abort
  " check if we have gogetdoc as it gives us more and accurate information.
  " Only supported if we have json_decode as it's not worth to parse the plain
  " non-json output of gogetdoc
  let bin_path = go#path#CheckBinPath('gogetdoc')
  if !empty(bin_path) && exists('*json_decode')
    let [l:json_out, l:err] = s:gogetdoc(1)
    if l:err
      call go#util#EchoError(json_out)
      return
    endif

    let out = json_decode(json_out)
    if type(out) != type({})
      call go#util#EchoError("gogetdoc output is malformed")
    endif

    let import = out["import"]
    let name = out["name"]
    let decl = out["decl"]

    let godoc_url = go#config#DocUrl()
    let godoc_url .= "/" . import
    if decl !~ "^package"
      let godoc_url .= "#" . name
    endif

    call go#tool#OpenBrowser(godoc_url)
    return
  endif

  let pkgs = s:godocWord(a:000)
  if empty(pkgs)
    return
  endif

  let pkg = pkgs[0]
  let exported_name = pkgs[1]

  " example url: https://godoc.org/github.com/fatih/set#Set
  let godoc_url = go#config#DocUrl() . "/" . pkg . "#" . exported_name
  call go#tool#OpenBrowser(godoc_url)
endfunction

function! go#doc#Open(newmode, mode, ...) abort
  " With argument: run "godoc [arg]".
  if len(a:000)
    let [l:out, l:err] = go#util#Exec(['go', 'doc'] + a:000)
  else " Without argument: run gogetdoc on cursor position.
    let [l:out, l:err] = s:gogetdoc(0)
    if out == -1
      return
    endif
  endif

  if l:err
    call go#util#EchoError(out)
    return
  endif

  call s:GodocView(a:newmode, a:mode, out)
endfunction

function! s:GodocView(newposition, position, content) abort
  " reuse existing buffer window if it exists otherwise create a new one
  let is_visible = bufexists(s:buf_nr) && bufwinnr(s:buf_nr) != -1
  if !bufexists(s:buf_nr)
    execute a:newposition
    sil file `="[Godoc]"`
    let s:buf_nr = bufnr('%')
  elseif bufwinnr(s:buf_nr) == -1
    execute a:position
    execute s:buf_nr . 'buffer'
  elseif bufwinnr(s:buf_nr) != bufwinnr('%')
    execute bufwinnr(s:buf_nr) . 'wincmd w'
  endif

  " if window was not visible then resize it
  if !is_visible
    if a:position == "split"
      " cap window height to 20, but resize it for smaller contents
      let max_height = go#config#DocMaxHeight()
      let content_height = len(split(a:content, "\n"))
      if content_height > max_height
        exe 'resize ' . max_height
      else
        exe 'resize ' . content_height
      endif
    else
      " set a sane maximum width for vertical splits. In this case the minimum
      " that fits the godoc for package http without extra linebreaks and line
      " numbers on
      exe 'vertical resize 84'
    endif
  endif

  setlocal filetype=godoc
  setlocal bufhidden=delete
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nocursorline
  setlocal nocursorcolumn
  setlocal iskeyword+=:
  setlocal iskeyword-=-

  setlocal modifiable
  %delete _
  call append(0, split(a:content, "\n"))
  sil $delete _
  setlocal nomodifiable
  sil normal! gg

  " close easily with enter
  noremap <buffer> <silent> <CR> :<C-U>close<CR>
  noremap <buffer> <silent> <Esc> :<C-U>close<CR>
  " make sure any key that sends an escape as a prefix (e.g. the arrow keys)
  " don't cause the window to close.
  nnoremap <buffer> <silent> <Esc>[ <Esc>[
endfunction

function! s:gogetdoc(json) abort
  let l:cmd = [
        \ 'gogetdoc',
        \ '-tags', go#config#BuildTags(),
        \ '-pos', expand("%:p:gs!\\!/!") . ':#' . go#util#OffsetCursor()]
  if a:json
    let l:cmd += ['-json']
  endif

  if &modified
    let l:cmd += ['-modified']
    return go#util#Exec(l:cmd, go#util#archive())
  endif

  return go#util#Exec(l:cmd)
endfunction

" returns the package and exported name. exported name might be empty.
" ie: fmt and Println
" ie: github.com/fatih/set and New
function! s:godocWord(args) abort
  if !executable('godoc')
    let msg = "godoc command not found."
    let msg .= "  install with: go get golang.org/x/tools/cmd/godoc"
    call go#util#EchoWarning(msg)
    return []
  endif

  if !len(a:args)
    let oldiskeyword = &iskeyword
    setlocal iskeyword+=.
    let word = expand('<cword>')
    let &iskeyword = oldiskeyword
    let word = substitute(word, '[^a-zA-Z0-9\\/._~-]', '', 'g')
    let words = split(word, '\.\ze[^./]\+$')
  else
    let words = a:args
  endif

  if !len(words)
    return []
  endif

  let pkg = words[0]
  if len(words) == 1
    let exported_name = ""
  else
    let exported_name = words[1]
  endif

  let packages = go#tool#Imports()

  if has_key(packages, pkg)
    let pkg = packages[pkg]
  endif

  return [pkg, exported_name]
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======
"
" godoc.vim: Vim command to see godoc.
"
"
" Commands:
"
"   :GoDoc
"
"       Open the relevant Godoc for either the word[s] passed to the command or
"       the, by default, the word under the cursor.
"
" Options:
"
"   g:go_godoc_commands [default=1]
"
"       Flag to indicate whether to enable the commands listed above.

let s:buf_nr = -1

if !exists("g:go_doc_command")
    let g:go_doc_command = "godoc"
endif

if !exists("g:go_doc_options")
    let g:go_doc_options = ""
endif

" returns the package and exported name. exported name might be empty.
" ie: fmt and Println
" ie: github.com/fatih/set and New
function! s:godocWord(args)
    if !executable('godoc')
        echohl WarningMsg
        echo "godoc command not found."
        echo "  install with: go get golang.org/x/tools/cmd/godoc"
        echohl None
        return []
    endif

    if !len(a:args)
        let oldiskeyword = &iskeyword
        setlocal iskeyword+=.
        let word = expand('<cword>')
        let &iskeyword = oldiskeyword
        let word = substitute(word, '[^a-zA-Z0-9\\/._~-]', '', 'g')
        let words = split(word, '\.\ze[^./]\+$')
    else
        let words = a:args
    endif

    if !len(words)
        return []
    endif

    let pkg = words[0]
    if len(words) == 1
        let exported_name = ""
    else
        let exported_name = words[1]
    endif

    let packages = go#tool#Imports()

    if has_key(packages, pkg)
        let pkg = packages[pkg]
    endif

    return [pkg, exported_name]
endfunction

function! s:godocNotFound(content)
    if len(a:content) == 0
        return 1
    endif

    return a:content =~# '^.*: no such file or directory\n$'
endfunction

function! go#doc#OpenBrowser(...)
    let pkgs = s:godocWord(a:000)
    if empty(pkgs)
        return
    endif

    let pkg = pkgs[0]
    let exported_name = pkgs[1]

    " example url: https://godoc.org/github.com/fatih/set#Set
    let godoc_url = "https://godoc.org/" . pkg . "#" . exported_name
    call go#tool#OpenBrowser(godoc_url)
endfunction

function! go#doc#Open(newmode, mode, ...)
    let pkgs = s:godocWord(a:000)
    if empty(pkgs)
        return
    endif

    let pkg = pkgs[0]
    let exported_name = pkgs[1]

    let command = g:go_doc_command . ' ' . g:go_doc_options . ' ' . pkg

    silent! let content = system(command)
    if v:shell_error || s:godocNotFound(content)
        echo 'No documentation found for "' . pkg . '".'
        return -1
    endif

    call s:GodocView(a:newmode, a:mode, content)

    if exported_name == ''
        silent! normal! gg
        return -1
    endif

    " jump to the specified name
    if search('^func ' . exported_name . '(')
        silent! normal! zt
        return -1
    endif

    if search('^type ' . exported_name)
        silent! normal! zt
        return -1
    endif

    if search('^\%(const\|var\|type\|\s\+\) ' . pkg . '\s\+=\s')
        silent! normal! zt
        return -1
    endif

    " nothing found, jump to top
    silent! normal! gg
endfunction

function! s:GodocView(newposition, position, content)
    " reuse existing buffer window if it exists otherwise create a new one
    if !bufexists(s:buf_nr)
        execute a:newposition
        sil file `="[Godoc]"`
        let s:buf_nr = bufnr('%')
    elseif bufwinnr(s:buf_nr) == -1
        execute a:position
        execute s:buf_nr . 'buffer'
    elseif bufwinnr(s:buf_nr) != bufwinnr('%')
        execute bufwinnr(s:buf_nr) . 'wincmd w'
    endif

    setlocal filetype=godoc
    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nocursorline
    setlocal nocursorcolumn
    setlocal iskeyword+=:
    setlocal iskeyword-=-

    setlocal modifiable
    %delete _
    call append(0, split(a:content, "\n"))
    sil $delete _
    setlocal nomodifiable
endfunction


" vim:ts=4:sw=4:et
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
