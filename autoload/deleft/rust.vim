let s:root_if_pattern = '^\s*\zs}\s*else\%(\s*if\)\=\>.*{\s*\%(//.*\)\='
let s:if_else_pattern = '^\s*\%(if\|}\s*else\s*if\|}\s*else\)\>.*\zs{\s*\%(//.*\)\='

function! deleft#rust#Parse()
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

  let start_line = line('.')

  " We first need to find the starting if-clause
  let previous_line = line('.')
  while search(s:root_if_pattern, 'Wcb', line('.'))
    normal! %

    if line('.') == previous_line
      " bracket-hopping failed, something's off
      return {}
    endif

    let previous_line = line('.')
  endwhile

  " Starting from the first if-clause, loop to the end
  while search(s:if_else_pattern, 'Wc', line('.'))
    let if_line = line('.')
    call add(match_info.delimiters, if_line)

    normal! %
    if line('.') == if_line
      " unmatched opening bracket, bail out
      return {}
    endif

    let group = [
          \ nextnonblank(if_line + 1),
          \ prevnonblank(line('.') - 1),
          \ ]

    if group[1] - group[0] < 0
      " then there's no lines in this group, nothing to do with it
      continue
    endif

    if if_line == start_line
      let match_info.current_group = group
    else
      call add(match_info.groups, group)
    endif
  endwhile

  " Last closing bracket
  call add(match_info.delimiters, line('.'))

  return match_info
endfunction
