if exists('g:loaded_deleft') || &cp
  finish
endif

let g:loaded_deleft = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

let s:indent_based_filetypes = ['coffee', 'python', 'haml', 'slim']

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

  " TODO (2020-06-14) Could be more reliable than going to the start of the
  " line, maybe, evaluate:
  "
  " if exists('b:match_words')
  "   " parse them, jump back to the nearest one that works
  "   let regex_parts = []
  "   for word_set in split(b:match_words, '\\\@<!,')
  "     for word in split(word_set, '\\\@<!:')
  "       call add(regex_parts, '\%('.word.'\)')
  "     endfor
  "   endfor
  "   let regex = join(regex_parts, '\|')
  "
  "   call search(regex, 'bWc', line('.'))
  "
  "   " TODO (2020-05-08) Properly execute skip pattern (s:, R:)
  "   " if exists('b:match_skip')
  "   "   let pattern = escape(b:match_skip, "'")
  "   "   let skip = "synIDattr(synID(line('.'),col('.'),1),'name') =~ '".pattern."'"
  "   " else
  "   "   let skip = ''
  "   " endif
  "   "
  "   " if search(regex, 'bWc', line('.')) > 0
  "   "   if skip != '' && eval(skip)
  "   "     while search(regex, 'bW', line('.')) > 0
  "   "       if !eval(skip)
  "   "         break
  "   "       endif
  "   "     endwhile
  "   "   endif
  "   " endif
  " endif

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
