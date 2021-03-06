" jfmt.vim: format json files with jq

if !exists('g:jfmt_jq_options')
  let g:jfmt_jq_options = ''
endif

if !exists('g:jfmt_jq_filter')
  let g:jfmt_jq_filter = '.'
endif


function! jfmt#GetLines()
  let buf = getline(1, '$')
  if &encoding != 'utf-8'
    let buf = map(buf, 'iconv(v:val, &encoding, "utf-8")')
  endif
  return buf
endfunction

function! jfmt#Sh(str) abort
  " Preserve original shell and shellredir values
  let l:shell = &shell
  let l:shellredir = &shellredir
  set shell=/bin/sh shellredir=>%s\ 2>&1

  try
    let l:output = call('system', [a:str] + a:000)
    return l:output
  finally
    " Restore original values
    let &shell = l:shell
    let &shellredir = l:shellredir
  endtry
endfunction

function! jfmt#Run(autofmt) abort
  " Save cursor position
  let l:curw = winsaveview()

  " Write current unsaved buffer to a temp file
  let l:tmpsrc = tempname()
  let l:tmptgt = tempname()
  call writefile(jfmt#GetLines(), l:tmpsrc)

  let cmd = ["jq"]
  call extend(cmd, split(g:jfmt_jq_options, " "))
  call add(cmd, g:jfmt_jq_filter)
  call add(cmd, l:tmpsrc)
  call add(cmd, "1>")
  call add(cmd, l:tmptgt)

  let out = jfmt#Sh(join(cmd, " "))

  if v:shell_error == 0
    let errors = []
    if a:autofmt == 1
      call jfmt#update_file(l:tmptgt, expand('%'))
    endif
  else
    let errors = jfmt#parse_error(expand('%'), out)
  endif
  call s:show_errors(errors)

  call delete(l:tmpsrc)

  " Restore cursor/windows positions
  call winrestview(l:curw)
endfunction

" update_file updates the target file with the given formatted source
function! jfmt#update_file(source, target)
  " remove undo point caused via BufWritePre
  try | silent undojoin | catch | endtry

  let old_fileformat = &fileformat
  if exists("*getfperm")
    " save file permissions
    let original_fperm = getfperm(a:target)
  endif

  call rename(a:source, a:target)

  " restore file permissions
  if exists("*setfperm") && original_fperm != ''
    call setfperm(a:target , original_fperm)
  endif

  " reload buffer to reflect latest changes
  silent! edit!

  let &fileformat = old_fileformat
  let &syntax = &syntax
endfunction

function! jfmt#parse_error(filename, content) abort
  let errors = []
  let line = matchstr(a:content, '.*line \zs.*\ze,')
  let col = matchstr(a:content, '.*column \zs.*\ze$')
  let text = matchstr(a:content, '.*: \zs.*\ze at line')
  call add(errors,{
        \"filename": a:filename,
        \"lnum":     line,
        \"col":      col,
        \"text":     text,
        \ })
  return errors
endfunction

function! s:show_errors(errors) abort
  let title = "Format"
  if !empty(a:errors)
    call setloclist(0, a:errors, 'r')
    " The last argument ({what}) is introduced with 7.4.2200:
    " https://github.com/vim/vim/commit/d823fa910cca43fec3c31c030ee908a14c272640
    if has("patch-7.4.2200") | call setloclist(0, [], 'a', {'title': title}) | endif
    echohl Error | echomsg "jq returned error" | echohl None
    lopen
  else
    lclose
  endif
endfunction

" vim: sw=2 ts=2 et
