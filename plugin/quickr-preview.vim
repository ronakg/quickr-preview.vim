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
if !exists("g:quickr_preview_sign_enable")
    let g:quickr_preview_sign_enable = 1
endif
if !exists("g:quickr_preview_sign_symbol")
    let g:quickr_preview_sign_symbol = ">>"
endif
if !exists("g:quickr_preview_sign_hl")
    let g:quickr_preview_sign_hl= "SignColumn"
endif
if !exists("g:quickr_preview_line_hl")
    let g:quickr_preview_line_hl= "Search"
endif
if !exists("g:quickr_preview_position")
    let g:quickr_preview_position = "above"
endif
" }}

function! QuickrPreviewExit()
    pclose!
    execute 'sign unplace 26'
endfunction

" I still don't have an answer to this question. Till then
" we'd have to settle with this workaround.
"
" https://stackoverflow.com/questions/36873661/set-bufdelete-autocmd-for-particular-filetype/
"
function! QuickrPreviewSetupExit()
    if &buftype == 'quickfix'
        autocmd BufDelete <buffer> call QuickrPreviewExit()
    endif
endfunction

augroup quickfix_cmds
    autocmd!
    autocmd BufCreate * call QuickrPreviewSetupExit()
augroup END

nnoremap <silent> <plug>(quickr_preview_qf_close) :cclose<CR>

if g:quickr_preview_keymaps
    nmap <leader>q <plug>(quickr_preview_qf_close)
endif

" Define a new sign for highlighting the current line in the preview window
if g:quickr_preview_sign_enable
    execute "sign define QuickrPreviewLine text=".g:quickr_preview_sign_symbol." texthl=".g:quickr_preview_sign_hl." linehl=".g:quickr_preview_line_hl
else
    execute "sign define QuickrPreviewLine linehl=".g:quickr_preview_line_hl
endif
