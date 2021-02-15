function! deleft#custom#Parse()
  if &ft == 'rust'
    return deleft#rust#Parse()
  else
    return {}
  endif
endfunction
