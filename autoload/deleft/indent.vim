function! deleft#indent#Run(mode)
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
