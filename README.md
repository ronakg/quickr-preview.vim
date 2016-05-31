# quickr-preview.vim

Quickly preview quickfix results in vim without opening the file. Usually when
one is browsing quickfix results, the file needs to be opened to see the result
in detail. This spoils the buffer list. `quickr-preview.vim` lets you preview
the result in detail without spoiling the buffer list. Everything is
automatically clened up once quickfix window is closed.

## Demo

[![asciicast](https://asciinema.org/a/47400.png)](https://asciinema.org/a/47400)

## Installation

This plugin follows the standard runtime path structure, and as such it can be
installed with a variety of plugin managers:

*  [Pathogen](https://github.com/tpope/vim-pathogen)
  - `git clone https://github.com/ronakg/quickr-preview.vim ~/.vim/bundle/quickr-preview.vim`
*  [NeoBundle](https://github.com/Shougo/neobundle.vim)
  - `NeoBundle 'ronakg/quickr-preview.vim'`
*  [Vundle](https://github.com/gmarik/vundle)
  - `Plugin 'ronakg/quickr-preview.vim'`
*  [Plug](https://github.com/junegunn/vim-plug)
  - `Plug 'ronakg/quickr-preview.vim'`
*  Manual
  - copy all of the files into your `~/.vim` directory


## Default Key maps

```vim
<leader><space> : Preview the quickfix result in a preview window
<enter>         : Open the quickfix result in a new buffer like usual
```

## Customization

### Disable default key mappings
If you want to use your own key mappings, you can disable the default key
mappings by adding following to your `~/.vimrc` file.

```vim
let g:quickr_preview_keymaps = 0
```

### Define custom key mappings

Use following `<plug>` to your own liking:

```vim
<plug>(quickr_preview)
```

For example:

```vim
nmap <leader>p <plug>(quickr_preview)
```

## FAQ

**Nothing happens when I press `<leader><space>` in quickfix window.**

Make sure `<leader><space>` is not defined to something else by invoking `:verbose map <leader><space>`.

## License
Copyright (c) Ronak Gandhi. Distributed under the same terms as Vim itself. See
`:help license`
