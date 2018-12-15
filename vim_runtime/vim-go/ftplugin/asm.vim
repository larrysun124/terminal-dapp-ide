" asm.vim: Vim filetype plugin for Go assembler.

if exists("b:did_ftplugin")
<<<<<<< HEAD
  finish
endif
let b:did_ftplugin = 1

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

=======
    finish
endif
let b:did_ftplugin = 1

>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
let b:undo_ftplugin = "setl fo< com< cms<"

setlocal formatoptions-=t

setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s

setlocal noexpandtab

command! -nargs=0 AsmFmt call go#asmfmt#Format()
<<<<<<< HEAD

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
