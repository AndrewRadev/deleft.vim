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
  let saved_view = winsaveview()
  normal! ^

  if index(s:indent_based_filetypes, &filetype) >= 0
    call deleft#Run({'indent': 1})
  else
    call deleft#Run({'indent': 0})
  endif

  call winrestview(saved_view)
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
