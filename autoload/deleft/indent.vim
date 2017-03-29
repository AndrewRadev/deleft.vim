function! deleft#indent#SimpleDeleft()
  " TODO (2017-03-29) Register?
  normal! dd

  let start_line = line('.')
  let end_line = deleft#indent#LowerIndentLimit(nextnonblank(start_line + 1))

  call deleft#Deindent(start_line, end_line)
endfunction

function! deleft#indent#LowerIndentLimit(lineno)
  let base_indent  = indent(a:lineno)
  let current_line = a:lineno
  let next_line    = nextnonblank(current_line + 1)

  while current_line < line('$') && indent(next_line) >= base_indent
    let current_line = next_line
    let next_line    = nextnonblank(current_line + 1)
  endwhile

  return current_line
endfunction
