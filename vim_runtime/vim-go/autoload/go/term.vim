<<<<<<< HEAD
" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

" new creates a new terminal with the given command. Mode is set based on the
" global variable g:go_term_mode, which is by default set to :vsplit
function! go#term#new(bang, cmd) abort
  return go#term#newmode(a:bang, a:cmd, go#config#TermMode())
endfunction

" new creates a new terminal with the given command and window mode.
function! go#term#newmode(bang, cmd, mode) abort
  let mode = a:mode
  if empty(mode)
    let mode = go#config#TermMode()
  endif

  let state = {
        \ 'cmd': a:cmd,
        \ 'bang' : a:bang,
        \ 'winid': win_getid(winnr()),
        \ 'stdout': []
      \ }

  " execute go build in the files directory
  let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
  let dir = getcwd()

  execute cd . fnameescape(expand("%:p:h"))

  execute mode.' __go_term__'

  setlocal filetype=goterm
  setlocal bufhidden=delete
  setlocal winfixheight
  setlocal noswapfile
  setlocal nobuflisted

  " explicitly bind callbacks to state so that within them, self will always
  " refer to state. See :help Partial for more information.
  "
  " Don't set an on_stderr, because it will be passed the same data as
  " on_stdout. See https://github.com/neovim/neovim/issues/2836
  let job = {
        \ 'on_stdout': function('s:on_stdout', [], state),
        \ 'on_exit' : function('s:on_exit', [], state),
      \ }

  let state.id = termopen(a:cmd, job)
  let state.termwinid = win_getid(winnr())

  execute cd . fnameescape(dir)

  " resize new term if needed.
  let height = go#config#TermHeight()
  let width = go#config#TermWidth()

  " Adjust the window width or height depending on whether it's a vertical or
  " horizontal split.
  if mode =~ "vertical" || mode =~ "vsplit" || mode =~ "vnew"
    exe 'vertical resize ' . width
  elseif mode =~ "split" || mode =~ "new"
    exe 'resize ' . height
  endif

  " we also need to resize the pty, so there you go...
  call jobresize(state.id, width, height)

  call win_gotoid(state.winid)

  return state.id
endfunction

function! s:on_stdout(job_id, data, event) dict abort
  call extend(self.stdout, a:data)
endfunction

function! s:on_exit(job_id, exit_status, event) dict abort
  let l:listtype = go#list#Type("_term")

  " usually there is always output so never branch into this clause
  if empty(self.stdout)
    call s:cleanlist(self.winid, l:listtype)
    return
  endif

  let errors = go#tool#ParseErrors(self.stdout)
  let errors = go#tool#FilterValids(errors)

  if !empty(errors)
    " close terminal; we don't need it anymore
    call win_gotoid(self.termwinid)
    close

    call win_gotoid(self.winid)

    let title = self.cmd
    if type(title) == v:t_list
      let title = join(self.cmd)
    endif
    call go#list#Populate(l:listtype, errors, title)
    call go#list#Window(l:listtype, len(errors))
    if !self.bang
      call go#list#JumpToFirst(l:listtype)
    endif

    return
  endif

  call s:cleanlist(self.winid, l:listtype)
endfunction

function! s:cleanlist(winid, listtype) abort
  " There are no errors. Clean and close the list. Jump to the window to which
  " the location list is attached, close the list, and then jump back to the
  " current window.
  let winid = win_getid(winnr())
  call win_gotoid(a:winid)
  call go#list#Clean(a:listtype)
  call win_gotoid(l:winid)
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======
if has('nvim') && !exists("g:go_term_mode")
    let g:go_term_mode = 'vsplit'
endif

" s:jobs is a global reference to all jobs started with new()
let s:jobs = {}

" new creates a new terminal with the given command. Mode is set based on the
" global variable g:go_term_mode, which is by default set to :vsplit
function! go#term#new(bang, cmd)
    return go#term#newmode(a:bang, a:cmd, g:go_term_mode)
endfunction

" new creates a new terminal with the given command and window mode.
function! go#term#newmode(bang, cmd, mode)
    let mode = a:mode
    if empty(mode)
        let mode = g:go_term_mode
    endif

    " modify GOPATH if needed
    let old_gopath = $GOPATH
    let $GOPATH = go#path#Detect()

    " execute go build in the files directory
    let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
    let dir = getcwd()

    execute cd . fnameescape(expand("%:p:h"))

    execute mode.' __go_term__'

    setlocal filetype=goterm
    setlocal bufhidden=delete
    setlocal winfixheight
    setlocal noswapfile
    setlocal nobuflisted

    let job = { 
                \ 'stderr' : [],
                \ 'stdout' : [],
                \ 'bang' : a:bang,
                \ 'on_stdout': function('s:on_stdout'),
                \ 'on_stderr': function('s:on_stderr'),
                \ 'on_exit' : function('s:on_exit'),
                \ }

    let id = termopen(a:cmd, job)

    execute cd . fnameescape(dir)

    " restore back GOPATH
    let $GOPATH = old_gopath

    let job.id = id
    startinsert

    " resize new term if needed.
    let height = get(g:, 'go_term_height', winheight(0))
    let width = get(g:, 'go_term_width', winwidth(0))

    " we are careful how to resize. for example it's vertical we don't change
    " the height. The below command resizes the buffer
    if a:mode == "split"
        exe 'resize ' . height
    elseif a:mode == "vertical"
        exe 'vertical resize ' . width
    endif

    " we also need to resize the pty, so there you go...
    call jobresize(id, width, height)

    let s:jobs[id] = job
    return id
endfunction

function! s:on_stdout(job_id, data)
    if !has_key(s:jobs, a:job_id)
        return
    endif
    let job = s:jobs[a:job_id]

    call extend(job.stdout, a:data)
endfunction

function! s:on_stderr(job_id, data)
    if !has_key(s:jobs, a:job_id)
        return
    endif
    let job = s:jobs[a:job_id]

    call extend(job.stderr, a:data)
endfunction

function! s:on_exit(job_id, data)
    if !has_key(s:jobs, a:job_id)
        return
    endif
    let job = s:jobs[a:job_id]

    let l:listtype = "locationlist"
    " usually there is always output so never branch into this clause
    if empty(job.stdout)
        call go#list#Clean(l:listtype)
        call go#list#Window(l:listtype)
    else
        let errors = go#tool#ParseErrors(job.stdout)
        let errors = go#tool#FilterValids(errors)
        if !empty(errors)
            " close terminal we don't need it
            close 

            call go#list#Populate(l:listtype, errors)
            call go#list#Window(l:listtype, len(errors))
            if !self.bang
                call go#list#JumpToFirst(l:listtype)
            endif
        else
            call go#list#Clean(l:listtype)
            call go#list#Window(l:listtype)
        endif

    endif

    unlet s:jobs[a:job_id]
endfunction

" vim:ts=4:sw=4:et
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
