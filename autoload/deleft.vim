function! deleft#Deindent(from, to)
  let saved_cursor = getpos('.')
  silent exe a:from.','.a:to.'<'
  call setpos('.', saved_cursor)
endfunction

function! deleft#Remove(start, end)
  let strategy = g:deleft_remove_strategy

  if strategy == 'none'
    " just deindent, and leave it
    call deleft#Deindent(a:start, a:end)
    return 1
  elseif strategy == 'delete'
    exe a:start.','.a:end.'delete _'
    return 1
  elseif strategy == 'comment'
    return s:Comment(a:start, a:end)
  elseif strategy == 'spaces'
    call deleft#Deindent(a:start, a:end)
    call append(a:end, '')
    call append(a:start - 1, '')
    return 1
  else
    echoerr
          \ "Unknown removal strategy: '".strategy."'."
          \ "Available strategies: 'none', 'delete', 'comment', 'spaces'."
    return 0
  endif
endfunction

function! deleft#Run(params)
  let indent_filetype = a:params.indent

  let match_info = deleft#custom#Parse()
  if match_info == {}
    let match_info = deleft#matchit#Parse({'indent': indent_filetype})
  endif

  if match_info == {}
    if indent_filetype
      return deleft#indent#SimpleDeleft()
    else
      return deleft#closing#SimpleDeleft()
    endif
  endif

  let [current_start, current_end] = match_info.current_group
  if current_start >= 0
    call deleft#Deindent(current_start, current_end)
  endif

  for entry in s:ItemsToRemove(match_info)
    let [type, line_range] = entry
    let [start, end] = line_range

    if type == 'delimiter'
      exe start.','.end.'delete _'
    elseif type == 'inactive_group'
      if !deleft#Remove(start, end)
        return
      endif
    else
      echoerr "Unknown type of an item to removed: '".type."'"
      return
    endif
  endfor
endfunction

function! deleft#Flatten(list)
  let flat_list = []

  for item in a:list
    if type(item) == type([])
      call extend(flat_list, deleft#Flatten(item))
    else
      call add(flat_list, item)
    endif
  endfor

  return flat_list
endfunction

function! s:Comment(start, end)
  if exists(':TComment')
    call deleft#Deindent(a:start, a:end)
    exe a:start.','.a:end.'TComment'
    return 1
  elseif exists(':Commentary')
    call deleft#Deindent(a:start, a:end)
    exe a:start.','.a:end.'Commentary'
    return 1
  elseif exists('g:loaded_nerd_comments')
    call deleft#Deindent(a:start, a:end)
    let saved_cursor = getpos('.')

    exe a:start
    if a:end > a:start
      exe 'normal! V'.(a:end - a:start).'j'
    else
      exe 'normal! V'
    endif

    exe "normal \<Plug>NERDCommenterComment"
    call setpos('.', saved_cursor)
    return 1
  else
    echoerr
          \ "No supported comment plugin installed."
          \ "Possible plugins: TComment"
    return 0
  endif
endfunction

" Iterate items to remove with their type, either "delimiter" or
" "inactive_group". This is done in one go, because any removal of lines
" offsets everything else
function! s:ItemsToRemove(match_info)
  let match_info = a:match_info
  let entries = []

  let all_lines = deleft#Flatten([match_info.groups, match_info.delimiters])
  let max_line = max(all_lines)
  let min_line = min(all_lines)
  let reversed_groups = reverse(copy(match_info.groups))

  let line = max_line
  while line >= min_line
    if index(match_info.delimiters, line) >= 0
      call add(entries, ['delimiter', [line, line]])
      let line -= 1
      continue
    endif

    if len(reversed_groups) == 0
      " no groups left, keep going with delimiters
      let line -= 1
      continue
    endif

    " does the line fit in the last group?
    let group = reversed_groups[0]
    if group[0] <= line && group[1] >= line
      let line = group[0] - 1
      call add(entries, ['inactive_group', remove(reversed_groups, 0)])
      continue
    endif

    let line -= 1
  endwhile

  return entries
endfunction
