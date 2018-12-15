" Copyright 2011 The Go Authors. All rights reserved.
" Use of this source code is governed by a BSD-style
" license that can be found in the LICENSE file.
"
<<<<<<< HEAD
" fmt.vim: Vim command to format Go files with gofmt (and gofmt compatible
" toorls, such as goimports).

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

"  we have those problems :
=======
" fmt.vim: Vim command to format Go files with gofmt.
"
" This filetype plugin add a new commands for go buffers:
"
"   :Fmt
"
"       Filter the current Go buffer through gofmt.
"       It tries to preserve cursor position and avoids
"       replacing the buffer with stderr output.
"
" Options:
"
"   g:go_fmt_command [default="gofmt"]
"
"       Flag naming the gofmt executable to use.
"
"   g:go_fmt_autosave [default=1]
"
"       Flag to auto call :Fmt when saved file
"

if !exists("g:go_fmt_command")
    let g:go_fmt_command = "gofmt"
endif

if !exists("g:go_goimports_bin")
    let g:go_goimports_bin = "goimports"
endif

if !exists('g:go_fmt_fail_silently')
    let g:go_fmt_fail_silently = 0
endif

if !exists('g:go_fmt_options')
    let g:go_fmt_options = ''
endif

if !exists("g:go_fmt_experimental")
    let g:go_fmt_experimental = 0
endif

"  we have those problems : 
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
"  http://stackoverflow.com/questions/12741977/prevent-vim-from-updating-its-undo-tree
"  http://stackoverflow.com/questions/18532692/golang-formatter-and-vim-how-to-destroy-history-record?rq=1
"
"  The below function is an improved version that aims to fix all problems.
"  it doesn't undo changes and break undo history.  If you are here reading
"  this and have VimL experience, please look at the function for
"  improvements, patches are welcome :)
<<<<<<< HEAD
function! go#fmt#Format(withGoimport) abort
  if go#config#FmtExperimental()
    " Using winsaveview to save/restore cursor state has the problem of
    " closing folds on save:
    "   https://github.com/fatih/vim-go/issues/502
    " One fix is to use mkview instead. Unfortunately, this sometimes causes
    " other bad side effects:
    "   https://github.com/fatih/vim-go/issues/728
    " and still closes all folds if foldlevel>0:
    "   https://github.com/fatih/vim-go/issues/732
    let l:curw = {}
    try
      mkview!
    catch
      let l:curw = winsaveview()
    endtry

    " save our undo file to be restored after we are done. This is needed to
    " prevent an additional undo jump due to BufWritePre auto command and also
    " restore 'redo' history because it's getting being destroyed every
    " BufWritePre
    let tmpundofile = tempname()
    exe 'wundo! ' . tmpundofile
  else
    " Save cursor position and many other things.
    let l:curw = winsaveview()
  endif

  " Write current unsaved buffer to a temp file
  let l:tmpname = tempname() . '.go'
  call writefile(go#util#GetLines(), l:tmpname)
  if go#util#IsWin()
    let l:tmpname = tr(l:tmpname, '\', '/')
  endif

  let bin_name = go#config#FmtCommand()
  if a:withGoimport == 1
    let bin_name = "goimports"
  endif

  let current_col = col('.')
  let [l:out, l:err] = go#fmt#run(bin_name, l:tmpname, expand('%'))
  let diff_offset = len(readfile(l:tmpname)) - line('$')

  if l:err == 0
    call go#fmt#update_file(l:tmpname, expand('%'))
  elseif !go#config#FmtFailSilently()
    let errors = s:parse_errors(expand('%'), out)
    call s:show_errors(errors)
  endif

  " We didn't use the temp file, so clean up
  call delete(l:tmpname)

  if go#config#FmtExperimental()
    " restore our undo history
    silent! exe 'rundo ' . tmpundofile
    call delete(tmpundofile)

    " Restore our cursor/windows positions, folds, etc.
    if empty(l:curw)
      silent! loadview
    else
      call winrestview(l:curw)
    endif
  else
    " Restore our cursor/windows positions.
    call winrestview(l:curw)
  endif

  " be smart and jump to the line the new statement was added/removed
  call cursor(line('.') + diff_offset, current_col)

  " Syntax highlighting breaks less often.
  syntax sync fromstart
endfunction

" update_file updates the target file with the given formatted source
function! go#fmt#update_file(source, target)
  " remove undo point caused via BufWritePre
  try | silent undojoin | catch | endtry

  let old_fileformat = &fileformat
  if exists("*getfperm")
    " save file permissions
    let original_fperm = getfperm(a:target)
  endif

  call rename(a:source, a:target)

  " restore file permissions
  if exists("*setfperm") && original_fperm != ''
    call setfperm(a:target , original_fperm)
  endif

  " reload buffer to reflect latest changes
  silent edit!

  let &fileformat = old_fileformat
  let &syntax = &syntax

  let l:listtype = go#list#Type("GoFmt")

  " the title information was introduced with 7.4-2200
  " https://github.com/vim/vim/commit/d823fa910cca43fec3c31c030ee908a14c272640
  if has('patch-7.4.2200')
    " clean up previous list
    if l:listtype == "quickfix"
      let l:list_title = getqflist({'title': 1})
    else
      let l:list_title = getloclist(0, {'title': 1})
    endif
  else
    " can't check the title, so assume that the list was for go fmt.
    let l:list_title = {'title': 'Format'}
  endif

  if has_key(l:list_title, "title") && l:list_title['title'] == "Format"
    call go#list#Clean(l:listtype)
  endif
endfunction

" run runs the gofmt/goimport command for the given source file and returns
" the output of the executed command. Target is the real file to be formatted.
function! go#fmt#run(bin_name, source, target)
  let l:cmd = s:fmt_cmd(a:bin_name, a:source, a:target)
  if empty(l:cmd)
    return
  endif
  return go#util#Exec(l:cmd)
endfunction

" fmt_cmd returns the command to run as a list.
function! s:fmt_cmd(bin_name, source, target)
  let l:cmd = [a:bin_name, '-w']

  " add the options for binary (if any). go_fmt_options was by default of type
  " string, however to allow customization it's now a dictionary of binary
  " name mapping to options.
  let opts = go#config#FmtOptions()
  if type(opts) == type({})
    let opts = has_key(opts, a:bin_name) ? opts[a:bin_name] : ""
  endif
  call extend(cmd, split(opts, " "))
  if a:bin_name is# 'goimports'
    call extend(cmd, ["-srcdir", a:target])
  endif

  call add(cmd, a:source)
  return cmd
endfunction

" parse_errors parses the given errors and returns a list of parsed errors
function! s:parse_errors(filename, content) abort
  let splitted = split(a:content, '\n')

  " list of errors to be put into location list
  let errors = []
  for line in splitted
    let tokens = matchlist(line, '^\(.\{-}\):\(\d\+\):\(\d\+\)\s*\(.*\)')
    if !empty(tokens)
      call add(errors,{
            \"filename": a:filename,
            \"lnum":     tokens[2],
            \"col":      tokens[3],
            \"text":     tokens[4],
            \ })
    endif
  endfor

  return errors
endfunction

" show_errors opens a location list and shows the given errors. If the given
" errors is empty, it closes the the location list
function! s:show_errors(errors) abort
  let l:listtype = go#list#Type("GoFmt")
  if !empty(a:errors)
    call go#list#Populate(l:listtype, a:errors, 'Format')
    echohl Error | echomsg "Gofmt returned error" | echohl None
  endif

  " this closes the window if there are no errors or it opens
  " it if there is any
  call go#list#Window(l:listtype, len(a:errors))
endfunction

function! go#fmt#ToggleFmtAutoSave() abort
  if go#config#FmtAutosave()
    call go#config#SetFmtAutosave(0)
    call go#util#EchoProgress("auto fmt disabled")
    return
  end

  call go#config#SetFmtAutosave(1)
  call go#util#EchoProgress("auto fmt enabled")
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======
function! go#fmt#Format(withGoimport)
    if g:go_fmt_experimental == 1
        " Using winsaveview to save/restore cursor state has the problem of
        " closing folds on save:
        "   https://github.com/fatih/vim-go/issues/502
        " One fix is to use mkview instead. Unfortunately, this sometimes causes
        " other bad side effects:
        "   https://github.com/fatih/vim-go/issues/728
        " and still closes all folds if foldlevel>0:
        "   https://github.com/fatih/vim-go/issues/732
        let l:curw = {}
        try
            mkview!
        catch
            let l:curw=winsaveview()
        endtry
    else
        " Save cursor position and many other things.
        let l:curw=winsaveview()
    endif

    " Write current unsaved buffer to a temp file
    let l:tmpname = tempname()
    call writefile(getline(1, '$'), l:tmpname)

    if g:go_fmt_experimental == 1
        " save our undo file to be restored after we are done. This is needed to
        " prevent an additional undo jump due to BufWritePre auto command and also
        " restore 'redo' history because it's getting being destroyed every
        " BufWritePre
        let tmpundofile=tempname()
        exe 'wundo! ' . tmpundofile
    endif

    " get the command first so we can test it
    let fmt_command = g:go_fmt_command
    if a:withGoimport  == 1 
        let fmt_command  = g:go_goimports_bin
    endif

    " check if the user has installed command binary.
    " For example if it's goimports, let us check if it's installed,
    " if not the user get's a warning via go#path#CheckBinPath()
    let bin_path = go#path#CheckBinPath(fmt_command)
    if empty(bin_path)
        return
    endif

    if fmt_command != "gofmt"
        " change GOPATH too, so goimports can pick up the correct library
        let old_gopath = $GOPATH
        let $GOPATH = go#path#Detect()

        let fmt_command = bin_path
    endif

    " populate the final command with user based fmt options
    let command = fmt_command . ' -w '
    if a:withGoimport  != 1 
        let command  = command . g:go_fmt_options
    endif

    if fmt_command == "goimports"
        if !exists('b:goimports_vendor_compatible')
            let out = system("goimports --help")
            if out !~ "-srcdir"
                echohl WarningMsg
                echomsg "vim-go: goimports does not support srcdir."
                echomsg "  update with: :GoUpdateBinaries"
                echohl None
            else
               let b:goimports_vendor_compatible = 1
            endif
        endif

        if exists('b:goimports_vendor_compatible') && b:goimports_vendor_compatible
            let command  = command . '-srcdir ' . fnameescape(expand("%:p:h"))
        endif
    endif

    " execute our command...
    let out = system(command . " " . l:tmpname)

    if fmt_command != "gofmt"
        let $GOPATH = old_gopath
    endif

    let l:listtype = "locationlist"
    "if there is no error on the temp file replace the output with the current
    "file (if this fails, we can always check the outputs first line with:
    "splitted =~ 'package \w\+')
    if v:shell_error == 0
        " remove undo point caused via BufWritePre
        try | silent undojoin | catch | endtry

        " Replace current file with temp file, then reload buffer
        let old_fileformat = &fileformat
        call rename(l:tmpname, expand('%'))
        silent edit!
        let &fileformat = old_fileformat
        let &syntax = &syntax

        " clean up previous location list, but only if it's due to fmt
        if exists('b:got_fmt_error') && b:got_fmt_error
            let b:got_fmt_error = 0
            call go#list#Clean(l:listtype)
            call go#list#Window(l:listtype)
        endif
    elseif g:go_fmt_fail_silently == 0
        let splitted = split(out, '\n')
        "otherwise get the errors and put them to location list
        let errors = []
        for line in splitted
            let tokens = matchlist(line, '^\(.\{-}\):\(\d\+\):\(\d\+\)\s*\(.*\)')
            if !empty(tokens)
                call add(errors, {"filename": @%,
                            \"lnum":     tokens[2],
                            \"col":      tokens[3],
                            \"text":     tokens[4]})
            endif
        endfor
        if empty(errors)
            % | " Couldn't detect gofmt error format, output errors
        endif
        if !empty(errors)
            call go#list#Populate(l:listtype, errors)
            echohl Error | echomsg "Gofmt returned error" | echohl None
        endif

        let b:got_fmt_error = 1
        call go#list#Window(l:listtype, len(errors))

        " We didn't use the temp file, so clean up
        call delete(l:tmpname)
    endif

    if g:go_fmt_experimental == 1
        " restore our undo history
        silent! exe 'rundo ' . tmpundofile
        call delete(tmpundofile)
    endif

    if g:go_fmt_experimental == 1
        " Restore our cursor/windows positions, folds, etc.
        if empty(l:curw)
            silent! loadview
        else
            call winrestview(l:curw)
        endif
    else
        " Restore our cursor/windows positions.
        call winrestview(l:curw)
    endif
endfunction


" vim:ts=4:sw=4:et
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
