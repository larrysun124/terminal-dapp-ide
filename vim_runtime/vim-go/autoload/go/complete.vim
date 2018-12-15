<<<<<<< HEAD
" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

function! s:gocodeCommand(cmd, args) abort
  let l:gocode_bin = "gocode"
  let l:gomod = go#util#gomod()
  if filereadable(l:gomod)
    " Save the file when in module mode so that go list can read the
    " imports. If the user doesn't have autowrite or autorwriteall enabled,
    " they'll need to write the file manually to get reliable results.
    " See https://github.com/fatih/vim-go/pull/1988#issuecomment-428576989.
    "
    " TODO(bc): don't save the file when in module mode once
    " golang.org/x/tools/go/packages has support for an overlay and it's used
    " by gocode.
    call go#cmd#autowrite()
    let l:gocode_bin = "gocode-gomod"
  endif

  let bin_path = go#path#CheckBinPath(l:gocode_bin)
  if empty(bin_path)
    return []
  endif

  let socket_type = go#config#GocodeSocketType()

  let cmd = [bin_path]
  let cmd = extend(cmd, ['-sock', socket_type])
  let cmd = extend(cmd, ['-f', 'vim'])

  if go#config#GocodeProposeBuiltins()
    let cmd = extend(cmd, ['-builtin'])
  endif

  if go#config#GocodeProposeSource()
    let cmd = extend(cmd, ['-source'])
  else
    let cmd = extend(cmd, ['-fallback-to-source'])
  endif

  if go#config#GocodeUnimportedPackages()
    let cmd = extend(cmd, ['-unimported-packages'])
  endif

  let cmd = extend(cmd, [a:cmd])
  let cmd = extend(cmd, a:args)

  return cmd
endfunction

function! s:sync_gocode(cmd, args, input) abort
  " We might hit cache problems, as gocode doesn't handle different GOPATHs
  " well. See: https://github.com/nsf/gocode/issues/239
  let old_goroot = $GOROOT
  let $GOROOT = go#util#env("goroot")

  try
    let cmd = s:gocodeCommand(a:cmd, a:args)
    " gocode can sometimes be slow, so redraw now to avoid waiting for gocode
    " to return before redrawing automatically.
    redraw

    let [l:result, l:err] = go#util#Exec(cmd, a:input)
  finally
    let $GOROOT = old_goroot
  endtry

  if l:err != 0
    return "[0, []]"
  endif

  if &encoding != 'utf-8'
    let l:result = iconv(l:result, 'utf-8', &encoding)
  endif

  return l:result
endfunction

function! s:gocodeAutocomplete() abort
  " use the offset as is, because the cursor position is the position for
  " which autocomplete candidates are needed.
  return s:sync_gocode('autocomplete',
        \ [expand('%:p'), go#util#OffsetCursor()],
        \ go#util#GetLines())
endfunction

" go#complete#GoInfo returns the description of the identifier under the
" cursor.
function! go#complete#GetInfo() abort
  return s:sync_info(0)
endfunction

function! go#complete#Info(showstatus) abort
  if go#util#has_job(1)
    return s:async_info(1, a:showstatus)
  else
    return s:sync_info(1)
  endif
endfunction

function! s:async_info(echo, showstatus)
  let state = {'echo': a:echo}

  function! s:complete(job, exit_status, messages) abort dict
    if a:exit_status != 0
      return
    endif

    if &encoding != 'utf-8'
      let i = 0
      while i < len(a:messages)
        let a:messages[i] = iconv(a:messages[i], 'utf-8', &encoding)
        let i += 1
      endwhile
    endif

    let result = s:info_filter(self.echo, join(a:messages, "\n"))
    call s:info_complete(self.echo, result)
  endfunction
  " explicitly bind complete to state so that within it, self will
  " always refer to state. See :help Partial for more information.
  let state.complete = function('s:complete', [], state)

  " add 1 to the offset, so that the position at the cursor will be included
  " in gocode's search
  let offset = go#util#OffsetCursor()+1

  " We might hit cache problems, as gocode doesn't handle different GOPATHs
  " well. See: https://github.com/nsf/gocode/issues/239
  let env = {
    \ "GOROOT": go#util#env("goroot")
    \ }

  let opts = {
        \ 'bang': 1,
        \ 'complete': state.complete,
        \ 'for': '_',
        \ }

  if a:showstatus
    let opts.statustype = 'gocode'
  endif

  let opts = go#job#Options(l:opts)

  let cmd = s:gocodeCommand('autocomplete',
        \ [expand('%:p'), offset])

  " TODO(bc): Don't write the buffer to a file; pass the buffer directly to
  " gocode's stdin. It shouldn't be necessary to use {in_io: 'file', in_name:
  " s:gocodeFile()}, but unfortunately {in_io: 'buffer', in_buf: bufnr('%')}
  " doesn't work.
  call extend(opts, {
        \ 'env': env,
        \ 'in_io': 'file',
        \ 'in_name': s:gocodeFile(),
        \ })

  call go#job#Start(cmd, opts)
endfunction

function! s:gocodeFile()
  let file = tempname()
  call writefile(go#util#GetLines(), file)
  return file
endfunction

function! s:sync_info(echo)
  " add 1 to the offset, so that the position at the cursor will be included
  " in gocode's search
  let offset = go#util#OffsetCursor()+1

  let result = s:sync_gocode('autocomplete',
        \ [expand('%:p'), offset],
        \ go#util#GetLines())

  let result = s:info_filter(a:echo, result)
  return s:info_complete(a:echo, result)
endfunction

function! s:info_filter(echo, result) abort
  if empty(a:result)
    return ""
  endif

  let l:result = eval(a:result)
  if len(l:result) != 2
    return ""
  endif

  let l:candidates = l:result[1]
  if len(l:candidates) == 1
    " When gocode panics in vim mode, it returns
    "     [0, [{'word': 'PANIC', 'abbr': 'PANIC PANIC PANIC', 'info': 'PANIC PANIC PANIC'}]]
    if a:echo && l:candidates[0].info ==# "PANIC PANIC PANIC"
      return ""
    endif

    return l:candidates[0].info
  endif

  let filtered = []
  let wordMatch = '\<' . expand("<cword>") . '\>'
  " escape single quotes in wordMatch before passing it to filter
  let wordMatch = substitute(wordMatch, "'", "''", "g")
  let filtered = filter(l:candidates, "v:val.info =~ '".wordMatch."'")

  if len(l:filtered) != 1
    return ""
  endif

  return l:filtered[0].info
endfunction

function! s:info_complete(echo, result) abort
  if a:echo && !empty(a:result)
    echo "vim-go: " | echohl Function | echon a:result | echohl None
  endif

  return a:result
endfunction

function! s:trim_bracket(val) abort
  let a:val.word = substitute(a:val.word, '[(){}\[\]]\+$', '', '')
  return a:val
endfunction

let s:completions = ""
function! go#complete#Complete(findstart, base) abort
  "findstart = 1 when we need to get the text length
  if a:findstart == 1
    execute "silent let s:completions = " . s:gocodeAutocomplete()
    return col('.') - s:completions[0] - 1
    "findstart = 0 when we need to return the list of completions
  else
    let s = getline(".")[col('.') - 1]
    if s =~ '[(){}\{\}]'
      return map(copy(s:completions[1]), 's:trim_bracket(v:val)')
    endif

    return s:completions[1]
  endif
endfunction

function! go#complete#ToggleAutoTypeInfo() abort
  if go#config#AutoTypeInfo()
    call go#config#SetAutoTypeInfo(0)
    call go#util#EchoProgress("auto type info disabled")
    return
  end

  call go#config#SetAutoTypeInfo(1)
  call go#util#EchoProgress("auto type info enabled")
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======
if !exists("g:go_gocode_bin")
    let g:go_gocode_bin = "gocode"
endif


fu! s:gocodeCurrentBuffer()
    let buf = getline(1, '$')
    if &encoding != 'utf-8'
        let buf = map(buf, 'iconv(v:val, &encoding, "utf-8")')
    endif
    if &l:fileformat == 'dos'
        " XXX: line2byte() depend on 'fileformat' option.
        " so if fileformat is 'dos', 'buf' must include '\r'.
        let buf = map(buf, 'v:val."\r"')
    endif
    let file = tempname()
    call writefile(buf, file)

    return file
endf

if go#vimproc#has_vimproc()
    let s:vim_system = get(g:, 'gocomplete#system_function', 'vimproc#system2')
    let s:vim_shell_error = get(g:, 'gocomplete#shell_error_function', 'vimproc#get_last_status')
else
    let s:vim_system = get(g:, 'gocomplete#system_function', 'system')
    let s:vim_shell_error = ''
endif

fu! s:shell_error()
    if empty(s:vim_shell_error)
        return v:shell_error
    endif
    return call(s:vim_shell_error, [])
endf

fu! s:system(str, ...)
    return call(s:vim_system, [a:str] + a:000)
endf

fu! s:gocodeShellescape(arg)
    if go#vimproc#has_vimproc()
        return vimproc#shellescape(a:arg)
    endif
    try
        let ssl_save = &shellslash
        set noshellslash
        return shellescape(a:arg)
    finally
        let &shellslash = ssl_save
    endtry
endf

fu! s:gocodeCommand(cmd, preargs, args)
    for i in range(0, len(a:args) - 1)
        let a:args[i] = s:gocodeShellescape(a:args[i])
    endfor
    for i in range(0, len(a:preargs) - 1)
        let a:preargs[i] = s:gocodeShellescape(a:preargs[i])
    endfor

    let bin_path = go#path#CheckBinPath(g:go_gocode_bin)
    if empty(bin_path)
        return
    endif

    " we might hit cache problems, as gocode doesn't handle well different
    " GOPATHS: https://github.com/nsf/gocode/issues/239
    let old_gopath = $GOPATH
    let $GOPATH = go#path#Detect()

    let result = s:system(printf('%s %s %s %s', s:gocodeShellescape(bin_path), join(a:preargs), s:gocodeShellescape(a:cmd), join(a:args)))

    let $GOPATH = old_gopath

    if s:shell_error() != 0
        return "[\"0\", []]"
    else
        if &encoding != 'utf-8'
            let result = iconv(result, 'utf-8', &encoding)
        endif
        return result
    endif
endf

fu! s:gocodeCurrentBufferOpt(filename)
    return '-in=' . a:filename
endf

fu! s:gocodeAutocomplete()
    let filename = s:gocodeCurrentBuffer()
    let result = s:gocodeCommand('autocomplete',
                \ [s:gocodeCurrentBufferOpt(filename), '-f=vim'],
                \ [expand('%:p'), go#util#OffsetCursor()])
    call delete(filename)
    return result
endf

function! go#complete#GetInfo()
    let offset = go#util#OffsetCursor()+1
    let filename = s:gocodeCurrentBuffer()
    let result = s:gocodeCommand('autocomplete',
                \ [s:gocodeCurrentBufferOpt(filename), '-f=godit'],
                \ [expand('%:p'), offset])
    call delete(filename)

    " first line is: Charcount,,NumberOfCandidates, i.e: 8,,1
    " following lines are candiates, i.e:  func foo(name string),,foo(
    let out = split(result, '\n')

    " no candidates are found
    if len(out) == 1
        return ""
    endif

    " only one candiate is found
    if len(out) == 2
        return split(out[1], ',,')[0]
    endif

    " to many candidates are available, pick one that maches the word under the
    " cursor
    let infos = []
    for info in out[1:]
        call add(infos, split(info, ',,')[0])
    endfor

    let wordMatch = '\<' . expand("<cword>") . '\>'
    " escape single quotes in wordMatch before passing it to filter
    let wordMatch = substitute(wordMatch, "'", "''", "g")
    let filtered =  filter(infos, "v:val =~ '".wordMatch."'")

    if len(filtered) == 1
        return filtered[0]
    endif

    return ""
endfunction

function! go#complete#Info(auto)
    " auto is true if we were called by g:go_auto_type_info's autocmd
    let result = go#complete#GetInfo()
    if !empty(result)
        " if auto, and the result is a PANIC by gocode, hide it
        if a:auto && result ==# 'PANIC PANIC PANIC' | return | endif
        echo "vim-go: " | echohl Function | echon result | echohl None
    endif
endfunction

function! s:trim_bracket(val)
    let a:val.word = substitute(a:val.word, '[(){}\[\]]\+$', '', '')
    return a:val
endfunction

fu! go#complete#Complete(findstart, base)
    "findstart = 1 when we need to get the text length
    if a:findstart == 1
        execute "silent let g:gocomplete_completions = " . s:gocodeAutocomplete()
        return col('.') - g:gocomplete_completions[0] - 1
        "findstart = 0 when we need to return the list of completions
    else
        let s = getline(".")[col('.') - 1]
        if s =~ '[(){}\{\}]'
            return map(copy(g:gocomplete_completions[1]), 's:trim_bracket(v:val)')
        endif
        return g:gocomplete_completions[1]
    endif
endf

" vim:ts=4:sw=4:et
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
