function! deleft#Deindent(from, to)
  let saved_cursor = getpos('.')
  silent exe a:from.','.a:to.'<'
  call setpos('.', saved_cursor)
endfunction

function! deleft#Comment(start, end)
  " TODO (2017-03-07) Make this a generic strategy
  exe a:start.','.a:end.'TComment'
endfunction

function! deleft#Run(params)
  let indent_filetype = a:params.indent

  let matchit_info = deleft#matchit#Parse({'indent': indent_filetype})
  if matchit_info == {}
    if indent_filetype
      return deleft#indent#SimpleDeleft()
    else
      return deleft#closing#SimpleDeleft()
    endif
  endif

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
