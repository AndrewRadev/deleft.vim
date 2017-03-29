function! deleft#Deindent(from, to)
  let saved_cursor = getpos('.')
  silent exe a:from.','.a:to.'<'
  call setpos('.', saved_cursor)
endfunction

function! deleft#Remove(start, end)
  let strategy = g:deleft_remove_strategy

  if strategy == 'delete'
    exe a:start.','.a:end.'delete _'
    return 1
  elseif strategy == 'comment'
    if exists(':TComment')
      call deleft#Deindent(a:start, a:end)
      exe a:start.','.a:end.'TComment'
      return 1
    else
      echoerr
            \ "No supported comment plugin installed."
            \ "Possible plugins: TComment"
      return 0
    endif
  else
    echoerr
          \ "Unknown removal strategy: '".strategy."'."
          \ "Available strategies: 'delete', 'comment'."
    return 0
  endif
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

  for entry in matchit_info.ItemsToRemove()
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
