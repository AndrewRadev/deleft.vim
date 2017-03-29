function! deleft#closing#SimpleDeleft()
  if !exists('b:deleft_closing_pattern')
    let b:deleft_closing_pattern = '.'
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
          \ getline(current_lineno) =~ b:deleft_closing_pattern
      let found_end = 1
      break
    endif

    let current_lineno = nextnonblank(current_lineno + 1)
  endwhile

  let end_lineno = current_lineno

  if end_lineno - start_lineno > 1
    silent exe (start_lineno + 1).','.(end_lineno - 1).'<'

    if found_end
      " then the end line is the block-closer, delete it
      silent exe end_lineno.'delete _'
    endif
  endif

  silent exe start_lineno.'delete'
  echo
endfunction
