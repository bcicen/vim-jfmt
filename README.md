# vim-jfmt

`jfmt` is a simple plugin for vim to pretty-print and indent JSON files on save

## Installing

Ensure you have [jq](https://stedolan.github.io/jq/) installed and available in your local `$PATH`

Then, add to your `.vimrc` using your plugin manager of choice; e.g. vundle:
```
Plugin 'bcicen/vim-jfmt'
```

## Options

Additional options may be provided to jq by setting `g:jfmt_jq_options`

Use tabs instead of spaces for indentation:
```
let g:jfmt_jq_options = '--tab'
```
