if exists('g:loaded_deleft') || &cp
  finish
endif

let g:loaded_deleft = '0.1.1' " version number
let s:keepcpo = &cpo
set cpo&vim

" Initialize matchit, a requirement
if !exists('g:loaded_matchit')
  if has(':packadd')
    packadd matchit
  else
    runtime macros/matchit.vim
  endif
endif

let s:indent_based_filetypes = ['coffee', 'haml', 'slim', 'yaml']

if !exists('g:deleft_indent_based_filetypes')
  let g:deleft_indent_based_filetypes = []
endif

if !exists('g:deleft_mapping')
  let g:deleft_mapping = 'dh'
endif

if !exists('g:deleft_remove_strategy')
  " possible values: "none", "comment", "delete", "spaces"
  let g:deleft_remove_strategy = 'none'
endif

command! Deleft call s:Deleft()
if g:deleft_mapping != ''
  exe 'nnoremap <silent> '.g:deleft_mapping.' :silent Deleft<cr>'
endif

function! s:Deleft()
  let saved_view = winsaveview()
  normal! ^

  let indent_based_filetypes = []
  call extend(indent_based_filetypes, s:indent_based_filetypes)
  call extend(indent_based_filetypes, g:deleft_indent_based_filetypes)

  if index(indent_based_filetypes, &filetype) >= 0
    call deleft#Run({'indent': 1})
  else
    call deleft#Run({'indent': 0})
  endif

  call winrestview(saved_view)
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
