function! deleft#custom#Parse()
  if &ft == 'rust'
    return deleft#rust#Parse()
  elseif &ft == 'python'
    return deleft#python#Parse()
  else
    return {}
  endif
endfunction
