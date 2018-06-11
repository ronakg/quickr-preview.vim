" quick-preview.vim:  Quickly preview quickfix results without opening files
" Maintainer:         Ronak Gandhi <https://github.com/ronakg>
" Version:            1.0
" Website:            https://github.com/ronakg/quickr-preview.vim

" Setup {{
if exists('g:quickr_preview_loaded') || !has('quickfix')
    finish
endif
let g:quickr_preview_loaded = 1
" }}

" Options {{
if !exists('g:quickr_preview_keymaps')
    let g:quickr_preview_keymaps = 1
endif
if !exists('g:quickr_preview_line_hl')
    let g:quickr_preview_line_hl = 'Search'
endif
if !exists('g:quickr_preview_position')
    let g:quickr_preview_position = 'above'
endif
" }}

" Construct the command used to open the preview window
let g:quickr_preview_pedit_cmd =
    \ (g:quickr_preview_position =~? '\(below\|right\)' ? 'belowright' : 'aboveleft').
    \ (g:quickr_preview_position =~? '\(left\|right\)' ? ' vertical pedit' : ' pedit')

" Mappings {{
nnoremap <silent> <plug>(quickr_preview_qf_close) :cclose<CR>:lclose<CR>
if g:quickr_preview_keymaps
    nmap <leader>q <plug>(quickr_preview_qf_close)
endif
" }}

