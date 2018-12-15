if exists("b:current_syntax")
<<<<<<< HEAD
  finish
endif

if !exists("g:main_syntax")
  let g:main_syntax = 'html'
=======
    finish
endif

if !exists("main_syntax")
    let main_syntax = 'html'
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
endif

runtime! syntax/gotexttmpl.vim
runtime! syntax/html.vim
unlet b:current_syntax

<<<<<<< HEAD
syn cluster htmlPreproc add=gotplAction,goTplComment

let b:current_syntax = "gohtmltmpl"

" vim: sw=2 ts=2 et
=======
let b:current_syntax = "gohtmltmpl"

" vim:ts=4:sw=4:et
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
