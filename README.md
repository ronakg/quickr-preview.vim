# quickr-preview.vim

Quickly preview quickfix and location results in vim without opening the file. Usually when
one is browsing quickfix or location results, the file needs to be opened to see the result
in detail. This spoils the buffer list. `quickr-preview.vim` lets you preview the result in
detail without spoiling the buffer list. Everything is automatically cleaned up once quickfix
and/or location windows are closed.

### Demo

[![asciicast](https://asciinema.org/a/47400.png)](https://asciinema.org/a/47400)

### Installation

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

### Default Key maps

```vim
<leader><space> : Preview the quickfix/location result in a preview window
<enter>         : Open the quickfix/location result in a new buffer like usual
```
P.S.: `\` is the leader key by default. So the mapping is `\<space>` unless `<leader>`
key is mapped to something else. Note that pressing `<leader><space>` multiple times on
the same qiuckfix/location result will toggle the preview window.

### Customization

#### Disable default key mappings
If you want to use your own key mappings, you can disable the default key
mappings by adding following to your `~/.vimrc` file.

```vim
let g:quickr_preview_keymaps = 0
```

#### Define custom key mappings

##### Use following `<plug>` to preview quickfix/location results:

```vim
<plug>(quickr_preview)
```

For example:

```vim
nmap <leader>p <plug>(quickr_preview)
```

##### Use following `<plug>` to quickly close the quickfix/location window (and in turn preview window) from anywhere:

```vim
<plug>(quickr_preview_qf_close)
```

For example:

```vim
nmap <leader>q <plug>(quickr_preview_qf_close)
```

#### Configuring the preview window position
By default, the preview window appears above the quickfix list.  But you can configure it to appear to the 'left', the 'right', or 'below' the quickfix list:

```vim
let g:quickr_preview_position = 'below'
```

#### Configuring the preview window sign column
The symbol used in the sign column within the preview window can be disabled by
adding the following to your `~/.vimrc` file.

```vim
let g:quickr_preview_sign_enable = 0
```

The symbol and highlight group used for the sign column within the preview window
can be changed by adding the following to your `~/.vimrc` file.

```vim
let g:quickr_preview_sign_symbol = ">>"
let g:quickr_preview_sign_hl = "SignColumn"
```

#### Configuring the preview window current line
The highlight group used for the current line within the preview window can be
changed by adding the following to your `~/.vimrc` file.

```vim
let g:quickr_preview_line_hl = "Search"
```

### FAQ

**Nothing happens when I press `<leader><space>` in quickfix/location window.**

Make sure `<leader><space>` is not defined to something else by invoking `:verbose map <leader><space>`.

### License
Copyright (c) Ronak Gandhi. Distributed under the same terms as Vim itself. See
`:help license`
