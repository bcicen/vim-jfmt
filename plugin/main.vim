augroup fmtjson
  autocmd!
  autocmd BufWritePre *.json call fmtjson#Format()
augroup END

" vim: sw=2 ts=2 et
