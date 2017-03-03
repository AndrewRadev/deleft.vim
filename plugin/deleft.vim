if exists('g:loaded_deleft') || &cp
  finish
endif

let g:loaded_deleft = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

let s:indent_based_filetypes = ['coffee', 'python', 'haml', 'slim']

command! Deleft call s:Deleft()
nnoremap dh :call <SID>Deleft()<cr>

function! s:Deleft()
  if index(s:indent_based_filetypes, &filetype) >= 0
    " TODO (2017-03-01) Two levels or more? (Visual mode)
    call deleft#indent#Run('n')
  else
    call deleft#closing#Run()
  endif
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
