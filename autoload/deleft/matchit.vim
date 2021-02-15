function! deleft#matchit#Parse(params)
  if !exists('g:loaded_matchit')
    " matchit wouldn't work anyway
    return {}
  endif

  if !exists('b:match_words')
    " no special definitions for this buffer, wouldn't work
    return {}
  endif

  let indent_filetype = get(a:params, 'indent', 0)
  let matchit_info = {
        \ 'delimiters': [],
        \ 'current_group': [-1, -1],
        \ 'groups': [],
        \ }

  let initial_lineno = line('.')
  let base_indent = indent(initial_lineno)
  let current_delimiter = initial_lineno
  normal %
  let current_lineno = line('.')

  while 1
    if index(matchit_info.delimiters, current_lineno) >= 0
      " then either the cursor hasn't moved, or it's jumped to something we've
      " already covered, stop here
      break
    endif

    if indent(current_lineno) > base_indent
      " then this one doesn't count as a delimiter (for example, "return" for
      " the "function"/"endfunction" pair. Jump to the next match
      normal %
      let current_lineno = line('.')
      continue
    endif

    call add(matchit_info.delimiters, current_lineno)

    if current_lineno == initial_lineno
      " then we're back at the start, stop looking
      break
    endif

    " Jump to the next match
    normal %
    let current_lineno = line('.')
  endwhile

  if len(matchit_info.delimiters) <= 1
    " only one item? nothing to work with
    return {}
  endif

  call sort(matchit_info.delimiters, function("s:CompareNumbers"))

  if indent_filetype
    call s:ProcessIndentGroups(current_delimiter, matchit_info)
  else
    call s:ProcessDelimitedGroups(current_delimiter, matchit_info)
  endif

  return matchit_info
endfunction

function! s:ProcessIndentGroups(current_delimiter, matchit_info)
  let current_delimiter = a:current_delimiter
  let matchit_info = a:matchit_info

  let matchit_info.current_group = [
        \ nextnonblank(current_delimiter + 1),
        \ deleft#indent#LowerIndentLimit(nextnonblank(current_delimiter + 1))
        \ ]

  " Extract other groups
  for delimiter in matchit_info.delimiters
    if delimiter == current_delimiter
      " ignore, we've already stored it
      continue
    endif

    let current_group = [
        \ nextnonblank(delimiter + 1),
        \ deleft#indent#LowerIndentLimit(nextnonblank(delimiter + 1))
        \ ]
    call add(matchit_info.groups, current_group)
  endfor

  return matchit_info
endfunction

function! s:ProcessDelimitedGroups(current_delimiter, matchit_info)
  let current_delimiter = a:current_delimiter
  let matchit_info = a:matchit_info

  " Locate current group
  if current_delimiter == matchit_info.delimiters[-1]
    " then it's the last one, use the previous one instead
    let current_delimiter = matchit_info.delimiters[-2]
  endif
  let next_delimiter =
        \ matchit_info.delimiters[index(matchit_info.delimiters, current_delimiter) + 1]

  let matchit_info.current_group =
        \ [current_delimiter + 1, next_delimiter - 1]

  " Extract other groups (iterate in pairs)
  let index = 0
  for delimiter in matchit_info.delimiters
    if index + 1 >= len(matchit_info.delimiters)
      " we're at the last element, and we've covered it
      break
    endif

    let next_delimiter = matchit_info.delimiters[index + 1]
    let current_group = [delimiter + 1, next_delimiter - 1]
    let index += 1

    if current_group == matchit_info.current_group
      " we've already stored it, ignore
      continue
    endif

    if current_group[1] - current_group[0] >= 0
      " then there's at least one line in the group
      call add(matchit_info.groups, current_group)
    endif
  endfor

  " Check if we should ignore the current group, now that we're done with it
  " in the previous loop
  if matchit_info.current_group[1] - matchit_info.current_group[0] < 0
    " then there's no lines in the group
    let matchit_info.current_group = [-1, -1]
  endif

  return matchit_info
endfunction

function! s:CompareNumbers(first, second)
  return a:first - a:second
endfunction
