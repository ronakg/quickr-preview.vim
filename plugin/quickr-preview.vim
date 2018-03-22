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

function! QuickrFixExit()
    pclose!
    execute 'sign unplace 26'
endfunction

augroup quickfix_cmds
    autocmd!
    autocmd FileType qf autocmd BufDelete <buffer> call QuickrFixExit()
augroup END

nnoremap <silent> <plug>(quickr_preview_qf_close) :cclose<CR>

if g:quickr_preview_keymaps
    nmap <leader>q <plug>(quickr_preview_qf_close)
endif

" Define a new sign for highlighting the current line in the preview window
sign define QuickrPreviewLine text=>> linehl=Search texthl=ErrorMsg
