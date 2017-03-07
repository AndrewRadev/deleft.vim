function! deleft#Deindent(from, to)
  let saved_cursor = getpos('.')
  silent exe a:from.','.a:to.'<'
  call setpos('.', saved_cursor)
endfunction

function! deleft#MatchitInfo()
  if !exists('g:loaded_matchit')
    " matchit wouldn't work anyway
    return {}
  endif

  if !exists('b:match_words')
    " no special definitions for this buffer, wouldn't work
    return {}
  endif

  let saved_position = getpos('.')
  let matchit_info = {
        \ 'delimiters': [],
        \ 'current_group': [-1, -1],
        \ 'groups': [],
        \ }

  let initial_line = line('.')
  let current_delimiter = initial_line
  normal %
  let current_line = line('.')

  while 1
    if index(matchit_info.delimiters, current_line) >= 0
      " then either the cursor hasn't moved, or it's jumped to something we've
      " already covered, stop here
      break
    endif

    call add(matchit_info.delimiters, current_line)

    if current_line == initial_line
      " then we're back at the start, stop looking
      break
    endif

    " Jump to the next match
    normal %
    let current_line = line('.')
  endwhile

  if len(matchit_info.delimiters) <= 1
    " only one item? nothing to work with
    return {}
  endif

  call sort(matchit_info.delimiters, 'f')

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
    " then there's at least one line in the group
    let matchit_info.current_group = [-1, -1]
  endif

  return matchit_info
endfunction

function! deleft#Comment(start, end)
  " TODO (2017-03-07) Make this a generic strategy
  exe a:start.','.a:end.'TComment'
endfunction
