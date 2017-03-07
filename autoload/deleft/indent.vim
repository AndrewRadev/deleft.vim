function! deleft#indent#Run()
  let matchit_info = deleft#MatchitInfo()
  if matchit_info == {}
    return s:SimpleDeleft()
  endif

  " TODO (2017-03-07) Duplicated?
  "
  " TODO (2017-03-07) For indent-based, no closing one, so last one shouldn't
  " look upwards -- algorithm doesn't generalize?

  let [current_start, current_end] = matchit_info.current_group
  if current_start >= 0
    call deleft#Deindent(current_start, current_end)
  endif

  for group in matchit_info.groups
    let [start, end] = group
    call deleft#Deindent(start, end)
    call deleft#Comment(start, end)
  endfor

  for delimiter in reverse(copy(matchit_info.delimiters))
    silent exe delimiter.'delete _'
  endfor
endfunction

function! s:SimpleDeleft()
  normal! dd

  let start_line = line('.')

  let base_indent = indent(start_line)
  let end_line    = start_line
  let next_line   = nextnonblank(end_line + 1)

  while end_line < line('$') && indent(next_line) >= base_indent
    let end_line = next_line
    let next_line = nextnonblank(end_line + 1)
  endwhile

  call deleft#Deindent(start_line, end_line)
endfunction
