if exists('g:loaded_deleft') || &cp
  finish
endif

let g:loaded_deleft = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

let s:indent_based_filetypes = ['coffee', 'python', 'haml', 'slim']

command Deleft call s:Deleft()
nnoremap dh :call <SID>Deleft()<cr>

function! s:Deleft()
  if index(s:indent_based_filetypes, &filetype) >= 0
    " TODO (2017-03-01) Two levels or more? (Visual mode)
    call s:DeleftIndentBased('n')
  else
    call s:DeleftWithClosing()
  endif
endfunction

function! s:DeleftWithClosing()
  if !exists('b:dh_closing_pattern')
    let b:dh_closing_pattern = '.'
  end

  let start_lineno = line('.')
  let start_indent = indent(start_lineno)

  let current_lineno = nextnonblank(start_lineno + 1)
  let found_end = 0

  while current_lineno <= line('$')
    if indent(current_lineno) > indent(start_lineno)
      let current_lineno = nextnonblank(current_lineno + 1)
      continue
    endif

    if indent(current_lineno) == indent(start_lineno) &&
          \ getline(current_lineno) =~ b:dh_closing_pattern
      let found_end = 1
      break
    endif

    let current_lineno = nextnonblank(current_lineno + 1)
  endwhile

  let end_lineno = current_lineno

  if end_lineno - start_lineno > 1
    exe (start_lineno + 1).','.(end_lineno - 1).'<'

    if found_end
      " then the end line is the block-closer, delete it
      exe end_lineno.'delete _'
    endif
  endif

  exe start_lineno.'delete'
  echo
endfunction

function! s:DeleftIndentBased(mode)
  if a:mode ==# 'v'
    let start_line       = line("'<")
    let end_line         = line("'>")
    let new_current_line = nextnonblank(end_line + 1)

    if end_line == line('$')
      let indent = 0
    else
      let indent = indent(new_current_line) - indent(start_line)
    endif

    let amount = indent / &sw
    exe "'<,'>delete"
  else
    let amount = 1
    normal! dd
  endif

  let start = line('.')
  let end   = s:LowerIndentLimit(start)

  call s:DecreaseIndent(start, end, amount)
endfunction

function! s:LowerIndentLimit(lineno)
  let base_indent  = indent(a:lineno)
  let current_line = a:lineno
  let next_line    = nextnonblank(current_line + 1)

  while current_line < line('$') && indent(next_line) >= base_indent
    let current_line = next_line
    let next_line    = nextnonblank(current_line + 1)
  endwhile

  return current_line
endfunction

function! s:DecreaseIndent(from, to, amount)
  let saved_cursor = getpos('.')
  let command = repeat('<', a:amount)
  exe a:from.','.a:to.command
  call setpos('.', saved_cursor)
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
