if !exists('g:jfmt_on_save')
  let g:jfmt_on_save = 1
endif

augroup jfmt
  if g:jfmt_on_save == 1
    autocmd!
    autocmd BufWritePre *.json call jfmt#Format()
  endif
augroup END

" vim: sw=2 ts=2 et
