<<<<<<< HEAD
" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

function! go#cmd#autowrite() abort
  if &autowrite == 1 || &autowriteall == 1
    silent! wall
  else
    for l:nr in range(0, bufnr('$'))
      if buflisted(l:nr) && getbufvar(l:nr, '&modified')
        " Sleep one second to make sure people see the message. Otherwise it is
        " often immediacy overwritten by the async messages (which also don't
        " invoke the "hit ENTER" prompt).
        call go#util#EchoWarning('[No write since last change]')
        sleep 1
        return
      endif
    endfor
  endif
endfunction

" Build builds the source code without producing any output binary. We live in
" an editor so the best is to build it to catch errors and fix them. By
" default it tries to call simply 'go build', but it first tries to get all
" dependent files for the current folder and passes it to go build.
function! go#cmd#Build(bang, ...) abort
  " Create our command arguments. go build discards any results when it
  " compiles multiple packages. So we pass the `errors` package just as an
  " placeholder with the current folder (indicated with '.'). We also pass -i
  " that tries to install the dependencies, this has the side effect that it
  " caches the build results, so every other build is faster.
  let l:args =
        \ ['build', '-tags', go#config#BuildTags()] +
        \ map(copy(a:000), "expand(v:val)") +
        \ [".", "errors"]

  " Vim and Neovim async.
  if go#util#has_job()
    call s:cmd_job({
          \ 'cmd': ['go'] + args,
          \ 'bang': a:bang,
          \ 'for': 'GoBuild',
          \ 'statustype': 'build'
          \})

  " Vim 7.4 without async
  else
    let default_makeprg = &makeprg
    let &makeprg = "go " . join(go#util#Shelllist(args), ' ')

    let l:listtype = go#list#Type("GoBuild")
=======
if !exists("g:go_dispatch_enabled")
    let g:go_dispatch_enabled = 0
endif

function! go#cmd#autowrite()
    if &autowrite == 1
        silent wall
    endif
endfunction


" Build builds the source code without producting any output binary. We live in
" an editor so the best is to build it to catch errors and fix them. By
" default it tries to call simply 'go build', but it first tries to get all
" dependent files for the current folder and passes it to go build.
function! go#cmd#Build(bang, ...)
    " expand all wildcards(i.e: '%' to the current file name)
    let goargs = map(copy(a:000), "expand(v:val)")

    " escape all shell arguments before we pass it to make
    let goargs = go#util#Shelllist(goargs, 1)

    " create our command arguments. go build discards any results when it
    " compiles multiple packages. So we pass the `errors` package just as an
    " placeholder with the current folder (indicated with '.')
    let args = ["build"]  + goargs + [".", "errors"]

    " if we have nvim, call it asynchronously and return early ;)
    if has('nvim')
        call go#util#EchoProgress("building dispatched ...")
        call go#jobcontrol#Spawn(a:bang, "build", args)
        return
    endif

    let old_gopath = $GOPATH
    let $GOPATH = go#path#Detect()
    let default_makeprg = &makeprg
    let &makeprg = "go " . join(args, ' ')

    let l:listtype = go#list#Type("quickfix")
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
    " execute make inside the source folder so we can parse the errors
    " correctly
    let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
    let dir = getcwd()
    try
<<<<<<< HEAD
      execute cd . fnameescape(expand("%:p:h"))
      if l:listtype == "locationlist"
        silent! exe 'lmake!'
      else
        silent! exe 'make!'
      endif
      redraw!
    finally
      execute cd . fnameescape(dir)
=======
        execute cd . fnameescape(expand("%:p:h"))
        if g:go_dispatch_enabled && exists(':Make') == 2
            call go#util#EchoProgress("building dispatched ...")
            silent! exe 'Make'
        elseif l:listtype == "locationlist"
            silent! exe 'lmake!'
        else
            silent! exe 'make!'
        endif
        redraw!
    finally
        execute cd . fnameescape(dir)
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
    endtry

    let errors = go#list#Get(l:listtype)
    call go#list#Window(l:listtype, len(errors))
<<<<<<< HEAD
    if !empty(errors) && !a:bang
      call go#list#JumpToFirst(l:listtype)
    else
      call go#util#EchoSuccess("[build] SUCCESS")
    endif

    let &makeprg = default_makeprg
  endif
endfunction


" BuildTags sets or shows the current build tags used for tools
function! go#cmd#BuildTags(bang, ...) abort
  if a:0
    let v = a:1
    if v == '""' || v == "''"
      let v = ""
    endif
    call go#config#SetBuildTags(v)
    let tags = go#config#BuildTags()
    if empty(tags)
      call go#util#EchoSuccess("build tags are cleared")
    else
      call go#util#EchoSuccess("build tags are changed to: " . tags)
    endif

    return
  endif

  let tags = go#config#BuildTags()
  if empty(tags)
    call go#util#EchoSuccess("build tags are not set")
  else
    call go#util#EchoSuccess("current build tags: " . tags)
  endif
endfunction


" Run runs the current file (and their dependencies if any) in a new terminal.
function! go#cmd#RunTerm(bang, mode, files) abort
  let cmd = "go run "
  let tags = go#config#BuildTags()
  if len(tags) > 0
    let cmd .= "-tags " . go#util#Shellescape(tags) . " "
  endif

  if empty(a:files)
    let cmd .= go#util#Shelljoin(go#tool#Files())
  else
    let cmd .= go#util#Shelljoin(map(copy(a:files), "expand(v:val)"), 1)
  endif
  call go#term#newmode(a:bang, cmd, a:mode)
endfunction

" Run runs the current file (and their dependencies if any) and outputs it.
" This is intended to test small programs and play with them. It's not
" suitable for long running apps, because vim is blocking by default and
" calling long running apps will block the whole UI.
function! go#cmd#Run(bang, ...) abort
  if has('nvim')
    call go#cmd#RunTerm(a:bang, '', a:000)
    return
  endif

  if go#util#has_job()
    " NOTE(arslan): 'term': 'open' case is not implement for +jobs. This means
    " executions waiting for stdin will not work. That's why we don't do
    " anything. Once this is implemented we're going to make :GoRun async
  endif

  let cmd = "go run "
  let tags = go#config#BuildTags()
  if len(tags) > 0
    let cmd .= "-tags " . go#util#Shellescape(tags) . " "
  endif

  if go#util#IsWin()
    if a:0 == 0
      exec '!' . cmd . go#util#Shelljoin(go#tool#Files(), 1)
    else
      exec '!' . cmd . go#util#Shelljoin(map(copy(a:000), "expand(v:val)"), 1)
    endif

    if v:shell_error
      redraws! | echon "vim-go: [run] " | echohl ErrorMsg | echon "FAILED"| echohl None
    else
      redraws! | echon "vim-go: [run] " | echohl Function | echon "SUCCESS"| echohl None
    endif

    return
  endif

  " :make expands '%' and '#' wildcards, so they must also be escaped
  let default_makeprg = &makeprg
  if a:0 == 0
    let &makeprg = cmd . go#util#Shelljoin(go#tool#Files(), 1)
  else
    let &makeprg = cmd . go#util#Shelljoin(map(copy(a:000), "expand(v:val)"), 1)
  endif

  let l:listtype = go#list#Type("GoRun")

  if l:listtype == "locationlist"
    exe 'lmake!'
  else
    exe 'make!'
  endif

  let items = go#list#Get(l:listtype)
  let errors = go#tool#FilterValids(items)

  call go#list#Populate(l:listtype, errors, &makeprg)
  call go#list#Window(l:listtype, len(errors))
  if !empty(errors) && !a:bang
    call go#list#JumpToFirst(l:listtype)
  endif

  let &makeprg = default_makeprg
endfunction

" Install installs the package by simple calling 'go install'. If any argument
" is given(which are passed directly to 'go install') it tries to install
" those packages. Errors are populated in the location window.
function! go#cmd#Install(bang, ...) abort
  " use vim's job functionality to call it asynchronously
  if go#util#has_job()
    " expand all wildcards(i.e: '%' to the current file name)
    let goargs = map(copy(a:000), "expand(v:val)")

    call s:cmd_job({
          \ 'cmd': ['go', 'install', '-tags', go#config#BuildTags()] + goargs,
          \ 'bang': a:bang,
          \ 'for': 'GoInstall',
          \ 'statustype': 'install'
          \})
    return
  endif

  let default_makeprg = &makeprg

  " :make expands '%' and '#' wildcards, so they must also be escaped
  let goargs = go#util#Shelljoin(map(copy(a:000), "expand(v:val)"), 1)
  let &makeprg = "go install " . goargs

  let l:listtype = go#list#Type("GoInstall")
  " execute make inside the source folder so we can parse the errors
  " correctly
  let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
  let dir = getcwd()
  try
    execute cd . fnameescape(expand("%:p:h"))
    if l:listtype == "locationlist"
      silent! exe 'lmake!'
    else
      silent! exe 'make!'
    endif
    redraw!
  finally
    execute cd . fnameescape(dir)
  endtry

  let errors = go#list#Get(l:listtype)
  call go#list#Window(l:listtype, len(errors))
  if !empty(errors) && !a:bang
    call go#list#JumpToFirst(l:listtype)
  else
    call go#util#EchoSuccess("installed to ". go#path#Default())
  endif

  let &makeprg = default_makeprg
endfunction

" Generate runs 'go generate' in similar fashion to go#cmd#Build()
function! go#cmd#Generate(bang, ...) abort
  let default_makeprg = &makeprg

  " :make expands '%' and '#' wildcards, so they must also be escaped
  let goargs = go#util#Shelljoin(map(copy(a:000), "expand(v:val)"), 1)
  if go#util#ShellError() != 0
    let &makeprg = "go generate " . goargs
  else
    let gofiles = go#util#Shelljoin(go#tool#Files(), 1)
    let &makeprg = "go generate " . goargs . ' ' . gofiles
  endif

  let l:listtype = go#list#Type("GoGenerate")

  echon "vim-go: " | echohl Identifier | echon "generating ..."| echohl None
  if l:listtype == "locationlist"
    silent! exe 'lmake!'
  else
    silent! exe 'make!'
  endif
  redraw!

  let errors = go#list#Get(l:listtype)
  call go#list#Window(l:listtype, len(errors))
  if !empty(errors)
    if !a:bang
      call go#list#JumpToFirst(l:listtype)
    endif
  else
    redraws! | echon "vim-go: " | echohl Function | echon "[generate] SUCCESS"| echohl None
  endif

  let &makeprg = default_makeprg
endfunction

" ---------------------
" | Vim job callbacks |
" ---------------------

function! s:cmd_job(args) abort
  " autowrite is not enabled for jobs
  call go#cmd#autowrite()

  call go#job#Spawn(a:args.cmd, a:args)
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======

    if !empty(errors)
        if !a:bang
            call go#list#JumpToFirst(l:listtype)
        endif
    else
        call go#util#EchoSuccess("[build] SUCCESS")
    endif

    let &makeprg = default_makeprg
    let $GOPATH = old_gopath
endfunction


" Run runs the current file (and their dependencies if any) in a new terminal.
function! go#cmd#RunTerm(bang, mode, files)
    if empty(a:files)
        let cmd = "go run ".  go#util#Shelljoin(go#tool#Files())
    else
        let cmd = "go run ".  go#util#Shelljoin(map(copy(a:files), "expand(v:val)"), 1)
    endif
    call go#term#newmode(a:bang, cmd, a:mode)
endfunction

" Run runs the current file (and their dependencies if any) and outputs it.
" This is intented to test small programs and play with them. It's not
" suitable for long running apps, because vim is blocking by default and
" calling long running apps will block the whole UI.
function! go#cmd#Run(bang, ...)
    if has('nvim')
        call go#cmd#RunTerm(a:bang, '', a:000)
        return
    endif

    let old_gopath = $GOPATH
    let $GOPATH = go#path#Detect()

    if go#util#IsWin()
        exec '!go run ' . go#util#Shelljoin(go#tool#Files())
        if v:shell_error
            redraws! | echon "vim-go: [run] " | echohl ErrorMsg | echon "FAILED"| echohl None
        else
            redraws! | echon "vim-go: [run] " | echohl Function | echon "SUCCESS"| echohl None
        endif

        let $GOPATH = old_gopath
        return
    endif

    " :make expands '%' and '#' wildcards, so they must also be escaped
    let default_makeprg = &makeprg
    if a:0 == 0
        let &makeprg = 'go run ' . go#util#Shelljoin(go#tool#Files(), 1)
    else
        let &makeprg = "go run " . go#util#Shelljoin(map(copy(a:000), "expand(v:val)"), 1)
    endif

    let l:listtype = go#list#Type("quickfix")

    if g:go_dispatch_enabled && exists(':Make') == 2
        silent! exe 'Make'
    elseif l:listtype == "locationlist"
        exe 'lmake!'
    else
        exe 'make!'
    endif

    let items = go#list#Get(l:listtype)
    let errors = go#tool#FilterValids(items)

    call go#list#Populate(l:listtype, errors)
    call go#list#Window(l:listtype, len(errors))
    if !empty(errors) && !a:bang
        call go#list#JumpToFirst(l:listtype)
    endif

    let $GOPATH = old_gopath
    let &makeprg = default_makeprg
endfunction

" Install installs the package by simple calling 'go install'. If any argument
" is given(which are passed directly to 'go install') it tries to install those
" packages. Errors are populated in the location window.
function! go#cmd#Install(bang, ...)
    let default_makeprg = &makeprg

    " :make expands '%' and '#' wildcards, so they must also be escaped
    let goargs = go#util#Shelljoin(map(copy(a:000), "expand(v:val)"), 1)
    let &makeprg = "go install " . goargs

    let l:listtype = go#list#Type("quickfix")
    " execute make inside the source folder so we can parse the errors
    " correctly
    let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
    let dir = getcwd()
    try
        execute cd . fnameescape(expand("%:p:h"))
        if g:go_dispatch_enabled && exists(':Make') == 2
            call go#util#EchoProgress("building dispatched ...")
            silent! exe 'Make'
        elseif l:listtype == "locationlist"
            silent! exe 'lmake!'
        else
            silent! exe 'make!'
        endif
        redraw!
    finally
        execute cd . fnameescape(dir)
    endtry

    let errors = go#list#Get(l:listtype)
    call go#list#Window(l:listtype, len(errors))
    if !empty(errors)
        if !a:bang
            call go#list#JumpToFirst(l:listtype)
        endif
    else
        redraws! | echon "vim-go: " | echohl Function | echon "installed to ". $GOPATH | echohl None
    endif

    let &makeprg = default_makeprg
endfunction

" Test runs `go test` in the current directory. If compile is true, it'll
" compile the tests instead of running them (useful to catch errors in the
" test files). Any other argument is appendend to the final `go test` command
function! go#cmd#Test(bang, compile, ...)
    let args = ["test"]

    " don't run the test, only compile it. Useful to capture and fix errors or
    " to create a test binary.
    if a:compile
        call add(args, "-c")
    endif

    if a:0
        " expand all wildcards(i.e: '%' to the current file name)
        let goargs = map(copy(a:000), "expand(v:val)")

        call extend(args, goargs, 1)
    else
        " only add this if no custom flags are passed
        let timeout  = get(g:, 'go_test_timeout', '10s')
        call add(args, printf("-timeout=%s", timeout))
    endif

    if a:compile
        echon "vim-go: " | echohl Identifier | echon "compiling tests ..." | echohl None
    else
        echon "vim-go: " | echohl Identifier | echon "testing ..." | echohl None
    endif

    if has('nvim')
        if get(g:, 'go_term_enabled', 0)
            call go#term#new(a:bang, ["go"] + args)
        else
            call go#jobcontrol#Spawn(a:bang, "test", args)
        endif
        return
    endif

    call go#cmd#autowrite()
    redraw

    let command = "go " . join(args, ' ')

    let out = go#tool#ExecuteInDir(command)

    let l:listtype = "quickfix"

    if v:shell_error
        let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
        let dir = getcwd()
        try
            execute cd fnameescape(expand("%:p:h"))
            let errors = go#tool#ParseErrors(split(out, '\n'))
            let errors = go#tool#FilterValids(errors)
        finally
            execute cd . fnameescape(dir)
        endtry

        call go#list#Populate(l:listtype, errors)
        call go#list#Window(l:listtype, len(errors))
        if !empty(errors) && !a:bang
            call go#list#JumpToFirst(l:listtype)
        elseif empty(errors)
            " failed to parse errors, output the original content
            call go#util#EchoError(out)
        endif
        echon "vim-go: " | echohl ErrorMsg | echon "[test] FAIL" | echohl None
    else
        call go#list#Clean(l:listtype)
        call go#list#Window(l:listtype)

        if a:compile
            echon "vim-go: " | echohl Function | echon "[test] SUCCESS" | echohl None
        else
            echon "vim-go: " | echohl Function | echon "[test] PASS" | echohl None
        endif
    endif
endfunction

" Testfunc runs a single test that surrounds the current cursor position.
" Arguments are passed to the `go test` command.
function! go#cmd#TestFunc(bang, ...)
    " search flags legend (used only)
    " 'b' search backward instead of forward
    " 'c' accept a match at the cursor position
    " 'n' do Not move the cursor
    " 'W' don't wrap around the end of the file
    "
    " for the full list
    " :help search
    let test = search("func Test", "bcnW")

    if test == 0
        echo "vim-go: [test] no test found immediate to cursor"
        return
    end

    let line = getline(test)
    let name = split(split(line, " ")[1], "(")[0]
    let args = [a:bang, 0, "-run", name . "$"]

    if a:0
        call extend(args, a:000)
    endif

    call call('go#cmd#Test', args)
endfunction

" Coverage creates a new cover profile with 'go test -coverprofile' and opens
" a new HTML coverage page from that profile.
function! go#cmd#Coverage(bang, ...)
    let l:tmpname=tempname()

    let command = "go test -coverprofile=" . l:tmpname . ' ' . go#util#Shelljoin(a:000)


    let l:listtype = "quickfix"
    call go#cmd#autowrite()
    let out = go#tool#ExecuteInDir(command)
    if v:shell_error
        let errors = go#tool#ParseErrors(split(out, '\n'))
        call go#list#Populate(l:listtype, errors)
        call go#list#Window(l:listtype, len(errors))
        if !empty(errors) && !a:bang
            call go#list#JumpToFirst(l:listtype)
        endif
    else
        " clear previous location list 
        call go#list#Clean(l:listtype)
        call go#list#Window(l:listtype)

        let openHTML = 'go tool cover -html='.l:tmpname
        call go#tool#ExecuteInDir(openHTML)
    endif

    call delete(l:tmpname)
endfunction

" Generate runs 'go generate' in similar fashion to go#cmd#Build()
function! go#cmd#Generate(bang, ...)
    let default_makeprg = &makeprg

    let old_gopath = $GOPATH
    let $GOPATH = go#path#Detect()

    " :make expands '%' and '#' wildcards, so they must also be escaped
    let goargs = go#util#Shelljoin(map(copy(a:000), "expand(v:val)"), 1)
    if v:shell_error
        let &makeprg = "go generate " . goargs
    else
        let gofiles = go#util#Shelljoin(go#tool#Files(), 1)
        let &makeprg = "go generate " . goargs . ' ' . gofiles
    endif

    let l:listtype = go#list#Type("quickfix")

    echon "vim-go: " | echohl Identifier | echon "generating ..."| echohl None
    if g:go_dispatch_enabled && exists(':Make') == 2
        silent! exe 'Make'
    elseif l:listtype == "locationlist"
        silent! exe 'lmake!'
    else
        silent! exe 'make!'
    endif
    redraw!

    let errors = go#list#Get(l:listtype)
    call go#list#Window(l:listtype, len(errors))
    if !empty(errors) 
        if !a:bang
            call go#list#JumpToFirst(l:listtype)
        endif
    else
        redraws! | echon "vim-go: " | echohl Function | echon "[generate] SUCCESS"| echohl None
    endif

    let &makeprg = default_makeprg
    let $GOPATH = old_gopath
endfunction

" vim:ts=4:sw=4:et
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
