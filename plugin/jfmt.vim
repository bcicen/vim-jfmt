if !exists('g:jfmt_autofmt')
  let g:jfmt_autofmt = 0
endif

command! Jfmt call jfmt#Run(1)

augroup jfmt
  autocmd!
  autocmd BufWritePre *.json call jfmt#Run(g:jfmt_autofmt)
augroup END

" vim: sw=2 ts=2 et
