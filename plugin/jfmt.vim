augroup jfmt
  autocmd!
  autocmd BufWritePre *.json call jfmt#Format()
augroup END

" vim: sw=2 ts=2 et
