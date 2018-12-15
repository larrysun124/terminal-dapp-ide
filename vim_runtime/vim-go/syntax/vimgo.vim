if exists("b:current_syntax")
<<<<<<< HEAD
  finish
=======
    finish
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
endif

let b:current_syntax = "vimgo"

syn match   goInterface /^\S*/
syn region  goTitle start="\%1l" end=":"

hi def link goInterface Type
hi def link goTitle Label
<<<<<<< HEAD

" vim: sw=2 ts=2 et
=======
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
