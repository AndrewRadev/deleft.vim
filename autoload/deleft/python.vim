let s:if_else_pattern = '^\s*\zs\%(if\|elif\|else\)\>.*:\s*$'
let s:skip            = "synIDattr(synID(line('.'),col('.'),1),'name') != 'pythonConditional'"

function! deleft#python#Parse()
  if search(s:if_else_pattern, 'Wcn', line('.'))
    return s:ParseIfElse()
  else
    return {}
  endif
endfunction

function! s:ParseIfElse()
  let match_info = {
        \ 'delimiters':    [],
        \ 'current_group': [-1, -1],
        \ 'groups':        [],
        \ }
  let start_lineno = line('.')
  let whitespace   = repeat(' ', indent('.'))

  let if_pattern      = $'^{whitespace}\zsif\>.*:\s*$'
  let if_else_pattern = $'^{whitespace}\zs\%(if\|elif\|else\)\>.*:\s*$'

  " We first need to find the starting if-clause
  let lineno = search(if_pattern, 'Wcb', 0, 0, s:skip)
  let line   = getline(lineno)

  " Starting from the first if-clause, find next else/elif:
  while lineno
    let group = [
          \ nextnonblank(lineno + 1),
          \ deleft#indent#LowerIndentLimit(lineno + 1),
          \ ]

    if group[1] - group[0] < 0
      " then there's no lines in this group, nothing to do with it
      continue
    endif

    if lineno == start_lineno
      let match_info.current_group = group
    else
      call add(match_info.groups, group)
    endif

    call add(match_info.delimiters, lineno)

    let lineno = search(if_else_pattern, 'W')
    let line   = getline(lineno)

    if line =~ $'^{whitespace}if\>'
      " A different if-clause, which means we can stop
      break
    endif
  endwhile

  return match_info
endfunction
