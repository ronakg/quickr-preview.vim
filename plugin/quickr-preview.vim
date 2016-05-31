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

" Options {{
if !exists("g:quickr_preview_keymaps")
    let g:quickr_preview_keymaps = 1
endif
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

nnoremap <silent> <plug>(quickr_preview_qf_close) :cclose<CR>

if g:quickr_preview_keymaps
    nmap <leader>q <plug>(quickr_preview_qf_close)
endif
