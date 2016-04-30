" quick-preview.vim:  Quickly preview quickfix results without opening files
" Maintainer:         Ronak Gandhi <https://github.com/ronakg>
" Version:            1.0
" Website:            https://github.com/ronakg/quickr-preview.vim

" Setup {{
if exists("g:quickr_preview_loaded") || !has("quickfix")
    finish
endif
let g:quickr_preview_loaded = 1
" }}

function! QuickFixPClose()
    if &buftype == 'quickfix'
        autocmd BufDelete <buffer> pclose!
    endif
endfunction

augroup quickfix_cmds
    autocmd!
    autocmd BufCreate * call QuickFixPClose()
augroup END
