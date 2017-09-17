" Copyright 2011 The Go Authors. All rights reserved.
" Use of this source code is governed by a BSD-style
" license that can be found in the LICENSE file.
"
" fmt.vim: Vim command to format Go files with gofmt (and gofmt compatible
" toorls, such as goimports).

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

function! jfmt#Format() abort
  " Save cursor position and many other things.
  let l:curw = winsaveview()

  " Write current unsaved buffer to a temp file
  let l:tmpsrc = tempname()
  let l:tmptgt = tempname()
  call writefile(jfmt#GetLines(), l:tmpsrc)

  let cmd = ["jq ."]
  call add(cmd, l:tmpsrc)
  call add(cmd, "1>")
  call add(cmd, l:tmptgt)

  let out = jfmt#Sh(join(cmd, " "))

  if v:shell_error == 0
    call jfmt#update_file(l:tmptgt, expand('%'))
    let errors = []
  else
    let errors = jfmt#parse_error(expand('%'), out)
  endif
  call s:show_errors(errors)

  " We didn't use the temp file, so clean up
  "call delete(l:tmpsrc)

  " Restore our cursor/windows positions.
  " call winrestview(l:curw)
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

  " clean up previous location list
  "let l:listtype = "locationlist"
  "call go#list#Clean(l:listtype)
  "call go#list#Window(l:listtype)
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
