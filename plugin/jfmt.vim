if !exists('g:jfmt_autofmt')
  let g:jfmt_autofmt = 0
endif

command! Jfmt call jfmt#Format()

augroup jfmt
  if g:jfmt_autofmt == 1
    autocmd!
    autocmd BufWritePre *.json call jfmt#Format()
  endif
augroup END

" vim: sw=2 ts=2 et
