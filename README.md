# vim-jfmt

`jfmt` is a simple plugin for vim to automatically validate and format/pretty-print JSON files.

<p align="center"><img width="80%" src="https://raw.githubusercontent.com/bcicen/vim-jfmt/doc/jfmt.gif" alt="vim-jfmt"/></p>

## Installing

Ensure you have [jq](https://stedolan.github.io/jq/) installed and available in your local `$PATH`

Then, add to your `.vimrc` using your plugin manager of choice; e.g. vundle:
```vim
Plugin 'bcicen/vim-jfmt'
```

## Usage

By default, `jfmt` will only validate JSON files on save, opening a location list with any parse errors encountered.

To manually format/pretty-print the open file, use the `:Jfmt` command. To automatically run this on save as well, simply add the below to your `.vimrc`:
```vim
let g:jfmt_autofmt  = 1
```

## Options

Additional options may be provided to jq by setting `g:jfmt_jq_options`:

```vim
" use tabs instead of spaces for indentation
let g:jfmt_jq_options = '--tab'
```

Likewise, the default filter(`.`) can be changed by setting `g:jfmt_jq_filter`
