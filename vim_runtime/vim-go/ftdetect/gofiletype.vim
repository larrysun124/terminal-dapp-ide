<<<<<<< HEAD
" vint: -ProhibitAutocmdWithNoGroup

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

=======
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
" We take care to preserve the user's fileencodings and fileformats,
" because those settings are global (not buffer local), yet we want
" to override them for loading Go files, which are defined to be UTF-8.
let s:current_fileformats = ''
let s:current_fileencodings = ''

" define fileencodings to open as utf-8 encoding even if it's ascii.
function! s:gofiletype_pre(type)
<<<<<<< HEAD
  let s:current_fileformats = &g:fileformats
  let s:current_fileencodings = &g:fileencodings
  set fileencodings=utf-8 fileformats=unix
  let &l:filetype = a:type
=======
    let s:current_fileformats = &g:fileformats
    let s:current_fileencodings = &g:fileencodings
    set fileencodings=utf-8 fileformats=unix
    let &l:filetype = a:type
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
endfunction

" restore fileencodings as others
function! s:gofiletype_post()
<<<<<<< HEAD
  let &g:fileformats = s:current_fileformats
  let &g:fileencodings = s:current_fileencodings
endfunction

" Note: should not use augroup in ftdetect (see :help ftdetect)
=======
    let &g:fileformats = s:current_fileformats
    let &g:fileencodings = s:current_fileencodings
endfunction

>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
au BufNewFile *.go setfiletype go | setlocal fileencoding=utf-8 fileformat=unix
au BufRead *.go call s:gofiletype_pre("go")
au BufReadPost *.go call s:gofiletype_post()

au BufNewFile *.s setfiletype asm | setlocal fileencoding=utf-8 fileformat=unix
au BufRead *.s call s:gofiletype_pre("asm")
au BufReadPost *.s call s:gofiletype_post()

au BufRead,BufNewFile *.tmpl set filetype=gohtmltmpl

<<<<<<< HEAD
" remove the autocommands for modsim3, and lprolog files so that their
" highlight groups, syntax, etc. will not be loaded. *.MOD is included, so
" that on case insensitive file systems the module2 autocmds will not be
" executed.
au! BufNewFile,BufRead *.mod,*.MOD
" Set the filetype if the first non-comment and non-blank line starts with
" 'module <path>'.
au BufNewFile,BufRead go.mod call s:gomod()

fun! s:gomod()
  for l:i in range(1, line('$'))
    let l:l = getline(l:i)
    if l:l ==# '' || l:l[:1] ==# '//'
      continue
    endif

    if l:l =~# '^module .\+'
      set filetype=gomod
    endif

    break
  endfor
endfun

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======
" vim:ts=4:sw=4:et
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
