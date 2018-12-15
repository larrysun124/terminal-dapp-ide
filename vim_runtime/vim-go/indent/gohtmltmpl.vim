if exists("b:did_indent")
  finish
endif

runtime! indent/html.vim

" Indent Golang HTML templates
setlocal indentexpr=GetGoHTMLTmplIndent(v:lnum)
setlocal indentkeys+==else,=end

" Only define the function once.
if exists("*GetGoHTMLTmplIndent")
  finish
endif

<<<<<<< HEAD
" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

=======
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
function! GetGoHTMLTmplIndent(lnum)
  " Get HTML indent
  if exists('*HtmlIndent')
    let ind = HtmlIndent()
  else
    let ind = HtmlIndentGet(a:lnum)
  endif

  " The value of a single shift-width
  if exists('*shiftwidth')
    let sw = shiftwidth()
  else
    let sw = &sw
  endif

  " If need to indent based on last line
  let last_line = getline(a:lnum-1)
<<<<<<< HEAD
  if last_line =~ '^\s*{{-\=\s*\%(if\|else\|range\|with\|define\|block\).*}}'
=======
  if last_line =~ '^\s*{{\s*\%(if\|else\|range\|with\|define\|block\).*}}'
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
    let ind += sw
  endif

  " End of FuncMap block
  let current_line = getline(a:lnum)
<<<<<<< HEAD
  if current_line =~ '^\s*{{-\=\s*\%(else\|end\).*}}'
=======
  if current_line =~ '^\s*{{\s*\%(else\|end\).*}}'
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
    let ind -= sw
  endif

  return ind
endfunction
<<<<<<< HEAD

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
=======
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
